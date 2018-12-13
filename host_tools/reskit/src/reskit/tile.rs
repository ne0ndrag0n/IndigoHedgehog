use image::{ GenericImageView, DynamicImage };
use std::fs;
use std::process::exit;

pub struct TilesetGenerator {
    image: DynamicImage,
    palette: [ u16; 16 ]
}

impl TilesetGenerator {

    pub fn new( filename: &str ) -> Result< TilesetGenerator, &'static str > {
        let dynamic_image = match image::open( filename ) {
            Ok( img ) => {
                // Image dimensions must be a multiple of 8
                let ( x, y ) = img.dimensions();
                if x % 8 == 0 && y % 8 == 0 {
                    img
                } else {
                    return Err( "Image dimensions not multiple of 8!" )
                }
            },
            Err( _ ) => return Err( "Could not open image file!" )
        };

        Ok( TilesetGenerator {
            image: dynamic_image,
            palette: [
                0x0000,0x0800,0x0080,0x0880,0x0008,0x0808,0x0088,0x0CCC,
                0x0888,0x0E00,0x00E0,0x0EE0,0x000E,0x0E0E,0x00EE,0x0EEE
            ]
            /*
            [
                0x0000, 0x079c, 0x079d, 0x089d, 0x08ad, 0x08ad, 0x08be, 0x09be,
                0x09ce, 0x09ce, 0x09ce, 0x0acf, 0x0adf, 0x0adf, 0x0bef, 0x0bef
            ]
            */
        } )
    }

    fn get_nearest_colour( &self, r: u16, g: u16, b: u16 ) -> usize {
        // Take upper byte of each colour and move them into the correct BGR location
        let final_val =
            ( ( r & 0x00F0 ) >> 4 ) |
              ( g & 0x00F0 ) |
            ( ( b & 0x00F0 ) << 4 );

        for i in 0..self.palette.len() {
            if self.palette[ i ] == final_val {
                return i
            }
        }

        println!( "fatal: Palette entry not found: {} {} {} hex:({:#X})", r, g, b, final_val );
        exit( 2 );
    }

    pub fn generate( &mut self, outfile: &str ) -> i32 {
        let mut result = String::new();
        result += "OutputPattern:\n";

        // take self.image and split it into tiles, saving them to outfile
        let ( max_x, max_y ) = self.image.dimensions();

        for y in ( 0..max_y ).step_by( 8 ) {
            for x in ( 0..max_x ).step_by( 8 ) {
                let mut segment = String::new();

                for cell_y in 0..8 {
                    segment += "\tdc.l $";
                    for cell_x in 0..8 {
                        let pixel = self.image.get_pixel( cell_x + x, cell_y + y );

                        segment += &format!( "{:X}", self.get_nearest_colour( pixel[ 0 ].into(), pixel[ 1 ].into(), pixel[ 2 ].into() ) );
                    }
                    segment += "\n";
                }

                result += &( segment + "\n" );
            }
        }

        match fs::write( outfile, result ) {
            Ok( _ ) => 1,
            Err( _ ) => {
                println!( "fatal: Could not write file!" );
                4
            }
        }
    }

}
