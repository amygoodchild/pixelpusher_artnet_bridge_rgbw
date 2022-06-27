# pixelpusher_artnet_bridge_rgbw

Artnet bridge for pixelpusher, designed to work with rgbw pixels

Pixelpusher does not natively support artnet, so this is a little bridge that receives artnet data and sends it on to the pixelpusher in a format it likes.

This one is specifically designed to work with RGBW pixels which, again, the pixelpusher does not natively support.

The PP thinks it is receiving 3 pieces of information for every pixel (RGB), whereas actually we are sending it 4 (RGBW). It also does not receive this data as RGB WRG BWR BGW (nicely repeating rgbw) as you might initially expect but, rather, RGB GWR WBG BRW. This is because as the pixelpusher receives the data, it is flipping the first two bytes of every triplet, because it thinks the strip is GRB. I guess that is probably something that could be fixed elsewhere by telling it not to the flipping BUT there we are. It works for now. 
