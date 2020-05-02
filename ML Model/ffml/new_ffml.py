import matplotlib.pyplot as plt
import pathlib
import tensorflow as tf
from keras_preprocessing.image import ImageDataGenerator
from tensorflow_core.python.keras import Sequential
from tensorflow_core.python.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout

train_root_folder = 'images_14'
data_dir = pathlib.Path(train_root_folder)

IMG_WIDTH = 128
IMG_HEIGHT = 128
train_samples = 1281
batch_size = 128
epochs = 30
validation_samples = int(train_samples * 0.3)
class_number = 14

tf.config.experimental.set_memory_growth(tf.config.experimental.list_physical_devices('GPU')[0], True)

# Expand Training Data Set
## Augment and visualize data
image_gen_train = ImageDataGenerator(
    rescale=1. / 255,
    rotation_range=45,
    width_shift_range=.15,
    height_shift_range=.15,
    horizontal_flip=True,
    zoom_range=0.2
)

train_data_gen = image_gen_train.flow_from_directory(batch_size=batch_size,
                                                     directory=train_root_folder,
                                                     shuffle=True,
                                                     target_size=(IMG_HEIGHT, IMG_WIDTH),
                                                     class_mode='categorical')

image_gen_val = ImageDataGenerator(rescale=1. / 255)

val_data_gen = image_gen_val.flow_from_directory(batch_size=batch_size,
                                                 directory=train_root_folder,
                                                 shuffle=True,
                                                 target_size=(IMG_HEIGHT, IMG_WIDTH),
                                                 class_mode='categorical'
                                                 )

sample_training_images, _ = next(train_data_gen)
sample_validating_images, _ = next(val_data_gen)
sample_validating_images = sample_validating_images[:validation_samples]


def plot_images(images_arr):
    fig, axes = plt.subplots(1, 5, figsize=(20, 20))
    axes = axes.flatten()
    for img, ax in zip(images_arr, axes):
        ax.imshow(img)
        ax.axis('off')
    plt.tight_layout()
    plt.show()


print(sample_training_images.size)
print(sample_validating_images.size)
plot_images(sample_training_images[:5])
plot_images(sample_validating_images[:5])

# Create Model
model = Sequential([
    Conv2D(16, 3, padding='same', activation='relu', input_shape=(IMG_HEIGHT, IMG_WIDTH, 3)),
    MaxPooling2D(),
    Dropout(0.2),
    Conv2D(32, 3, padding='same', activation='relu'),
    MaxPooling2D(),
    Conv2D(64, 3, padding='same', activation='relu'),
    MaxPooling2D(),
    Dropout(0.2),
    Flatten(),
    Dense(512, activation='relu'),
    Dense(64, activation='relu'),
    Dense(class_number)
])

model.compile(optimizer='adam',
              loss=tf.keras.losses.CategoricalCrossentropy(from_logits=True),
              metrics=['accuracy'])

model.summary()

history = model.fit_generator(
    train_data_gen,
    steps_per_epoch=train_samples // batch_size,
    epochs=epochs,
    validation_data=val_data_gen,
    validation_steps=validation_samples // batch_size
)


tf.saved_model.save(model, 'saved_model')
converter = tf.lite.TFLiteConverter.from_saved_model('saved_model')
tflite_model = converter.convert()
open("saved_model/tflite/converted_model.tflite", "wb").write(tflite_model)

acc = history.history['accuracy']
val_acc = history.history['val_accuracy']

loss = history.history['loss']
val_loss = history.history['val_loss']

epochs_range = range(epochs)

plt.figure(figsize=(8, 8))
plt.subplot(1, 2, 1)
plt.plot(epochs_range, acc, label='Training Accuracy')
plt.plot(epochs_range, val_acc, label='Validation Accuracy')
plt.legend(loc='lower right')
plt.title('Training and Validation Accuracy')

plt.subplot(1, 2, 2)
plt.plot(epochs_range, loss, label='Training Loss')
plt.plot(epochs_range, val_loss, label='Validation Loss')
plt.legend(loc='upper right')
plt.title('Training and Validation Loss')
plt.show()
