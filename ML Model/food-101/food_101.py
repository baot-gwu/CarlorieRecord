from collections import defaultdict
from shutil import copy
from tensorflow.keras.models import load_model
import os
import tensorflow as tf
import tensorflow.keras.backend as K
from tensorflow.keras import regularizers
from tensorflow.keras.applications.inception_v3 import InceptionV3
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.layers import GlobalAveragePooling2D
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import ModelCheckpoint, CSVLogger
from tensorflow.keras.optimizers import SGD

# Parameters
data_dir = "food-101/images/"
src_train = 'food-101/train'
src_test = 'food-101/test'
n_classes = 101
img_width, img_height = 299, 299
train_data_dir = src_train
validation_data_dir = src_test
nb_train_samples = 75750
nb_validation_samples = 25250
batch_size = 16
epochs = 30
food_list = sorted(os.listdir(data_dir))

# Helper method to split dataset into train and test folders
def prepare_data(filepath, src, dest):
    classes_images = defaultdict(list)
    with open(filepath, 'r') as txt:
        paths = [read.strip() for read in txt.readlines()]
        for p in paths:
            food = p.split('/')
            classes_images[food[0]].append(food[1] + '.jpg')

    for food in classes_images.keys():
        print("\nCopying images into ", food)
        if not os.path.exists(os.path.join(dest, food)):
            os.makedirs(os.path.join(dest, food))
        for i in classes_images[food]:
            copy(os.path.join(src, food, i), os.path.join(dest, food, i))
    print("Copying Done!")


print("Creating train data...")
prepare_data('food-101/meta/train.txt', data_dir, src_train)
print("Creating test data...")
prepare_data('food-101/meta/test.txt', data_dir, src_test)

train_datagen = ImageDataGenerator(
    rescale=1. / 255,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True)

test_datagen = ImageDataGenerator(rescale=1. / 255)

train_generator = train_datagen.flow_from_directory(
    train_data_dir,
    target_size=(img_height, img_width),
    batch_size=batch_size,
    class_mode='categorical')

validation_generator = test_datagen.flow_from_directory(
    validation_data_dir,
    target_size=(img_height, img_width),
    batch_size=batch_size,
    class_mode='categorical')

# Enable GPU Memory Limit
gpus = tf.config.experimental.list_physical_devices('GPU')
if gpus:
    # Restrict TensorFlow to only allocate 2GB of memory on the first GPU
    try:
        tf.config.experimental.set_virtual_device_configuration(
            gpus[0],
            [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=2048)])
        logical_gpus = tf.config.experimental.list_logical_devices('GPU')
        print(len(gpus), "Physical GPUs,", len(logical_gpus), "Logical GPUs")
    except RuntimeError as e:
        # Virtual devices must be set before GPUs have been initialized
        print(e)

# Training Model
inception = InceptionV3(weights='imagenet', include_top=False)
x = inception.output
x = GlobalAveragePooling2D()(x)
x = Dense(128, activation='relu')(x)
x = Dropout(0.2)(x)

predictions = Dense(n_classes, kernel_regularizer=regularizers.l2(0.005), activation='softmax')(x)

model = Model(inputs=inception.input, outputs=predictions)
model.compile(optimizer=SGD(lr=0.0001, momentum=0.9), loss='categorical_crossentropy', metrics=['accuracy'])
checkpointer = ModelCheckpoint(filepath='food-101/model/best_food_model_101.hdf5', verbose=1, save_best_only=True,
                               monitor='val_accuracy')
csv_logger = CSVLogger('food-101/log/history_food_model_101.log')

history_101class = model.fit_generator(train_generator,
                                       steps_per_epoch=nb_train_samples // batch_size,
                                       validation_data=validation_generator,
                                       validation_steps=nb_validation_samples // batch_size,
                                       epochs=epochs,
                                       verbose=1,
                                       callbacks=[csv_logger, checkpointer])

# Save Model
model.save('food-101/model/food_model_101.hdf5')
tf.saved_model.save(model, 'food-101/model/saved_model_101')

K.clear_session()
model_best = load_model('best_model_101class.hdf5', compile=False)
tf.saved_model.save(model, 'food-101/model/best_model_101')
K.clear_session()
model_best = tf.saved_model.load('food-101/model/best_model_101')

# Convert into quantified tflite model
concrete_func = model_best.signatures[tf.saved_model.DEFAULT_SERVING_SIGNATURE_DEF_KEY]
concrete_func.inputs[0].set_shape([1, 299, 299, 3])
converter = tf.lite.TFLiteConverter.from_concrete_functions([concrete_func])
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()
open("food-101/model/best_model_101/tflite/food_model_101_quantified.tflite", "wb").write(tflite_model)
