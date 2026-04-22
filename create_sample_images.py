from PIL import Image, ImageDraw, ImageFont
import os

# Create temp_images directory if it doesn't exist
os.makedirs('temp_images', exist_ok=True)

# Create three sample profile images
colors = [
    ('#4A90E2', 'white', 'Profile 1'),
    ('#E94B3C', 'white', 'Profile 2'),
    ('#50C878', 'white', 'Profile 3'),
]

for i, (bg_color, text_color, text) in enumerate(colors, 1):
    # Create a new image
    img = Image.new('RGB', (400, 400), color=bg_color)
    draw = ImageDraw.Draw(img)
    
    # Try to use a default font, fallback to basic if not available
    try:
        font = ImageFont.truetype("arial.ttf", 40)
    except:
        font = ImageFont.load_default()
    
    # Draw text in the center
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((400 - text_width) // 2, (400 - text_height) // 2)
    draw.text(position, text, fill=text_color, font=font)
    
    # Save the image
    img.save(f'temp_images/profile{i}.jpg')
    print(f'Created profile{i}.jpg')

print('All sample images created successfully!')
