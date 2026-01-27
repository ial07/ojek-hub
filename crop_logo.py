from PIL import Image

def process_logo():
    input_path = 'frontend/assets/images/logo_kerjocurup.png'
    output_path = 'frontend/assets/images/logo_symbol_512.png'
    
    try:
        img = Image.open(input_path)
        width, height = img.size
        print(f"Original size: {width}x{height}")
        
        # 1. CROP: Keep top 82% to be safe (avoid cutting logo bottom) but remove text
        # If 65% cut the logo, then the logo goes deeper.
        # Text is usually very bottom. Let's try 82%.
        crop_height = int(height * 0.82)
        cropped_img = img.crop((0, 0, width, crop_height))
        
        # 2. TRIM: Remove transparent borders to find the true logo bounds
        bbox = cropped_img.getbbox()
        if bbox:
            cropped_img = cropped_img.crop(bbox)
            print(f"Trimmed size: {cropped_img.size}")
        
        # 3. SQUARE CANVAS: Create 512x512 transparent background
        final_size = 512
        new_img = Image.new("RGBA", (final_size, final_size), (0, 0, 0, 0))
        
        # 4. RESIZE & CENTER: Fit the trimmed logo into e.g. 400x400 (padding)
        # Leave some padding so it doesn't touch the edges of the circle
        padding = 60
        target_max = final_size - (padding * 2)
        
        # Calculate aspect maintaining resize
        cw, ch = cropped_img.size
        ratio = min(target_max / cw, target_max / ch)
        new_w = int(cw * ratio)
        new_h = int(ch * ratio)
        
        resized_logo = cropped_img.resize((new_w, new_h), Image.Resampling.LANCZOS)
        
        # Paste in center
        x_offset = (final_size - new_w) // 2
        y_offset = (final_size - new_h) // 2
        
        new_img.paste(resized_logo, (x_offset, y_offset))
        
        new_img.save(output_path)
        print(f"Saved neat 512x512 icon to {output_path}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    process_logo()
