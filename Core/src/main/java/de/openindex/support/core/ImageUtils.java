/*
 * Copyright 2015-2018 OpenIndex.de.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package de.openindex.support.core;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferInt;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import javax.swing.ImageIcon;
import org.imgscalr.Scalr;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("WeakerAccess")
public class ImageUtils {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(ImageUtils.class);

    private ImageUtils() {
        super();
    }

    public static BufferedImage crop(BufferedImage image, int x, int y, int width, int height) {
        return Scalr.crop(image, x, y, width, height);
    }

    public static boolean equals(BufferedImage image1, BufferedImage image2) {
        final int image1Width = image1.getWidth();
        final int image1Height = image1.getHeight();

        final int image2Width = image2.getWidth();
        final int image2Height = image2.getHeight();

        if (image1Width != image2Width || image1Height != image2Height)
            return false;

        final DataBuffer image1Buffer = image1.getData().getDataBuffer();
        final DataBuffer image2Buffer = image2.getData().getDataBuffer();

        final int image1BufferSize = image1Buffer.getSize();
        final int image2BufferSize = image2Buffer.getSize();
        if (image1BufferSize != image2BufferSize)
            return false;

        if (image1Buffer instanceof DataBufferInt && image2Buffer instanceof DataBufferInt) {
            // compare according to https://stackoverflow.com/a/11006984
            final DataBufferInt image1BufferInt = (DataBufferInt) image1Buffer;
            final DataBufferInt image2BufferInt = (DataBufferInt) image2Buffer;
            if (image1BufferInt.getNumBanks() != image2BufferInt.getNumBanks())
                return false;

            for (int bank = 0; bank < image1BufferInt.getNumBanks(); bank++) {
                int[] actual = image1BufferInt.getData(bank);
                int[] expected = image2BufferInt.getData(bank);
                if (!Arrays.equals(actual, expected))
                    return false;
            }
        } else {
            // compare according to https://stackoverflow.com/a/51497360
            for (int i = 0; i < image1BufferSize; i++) {
                if (image1Buffer.getElem(i) != image2Buffer.getElem(i)) {
                    return false;
                }
            }
        }

        //for (int x = 0; x < image1Width; x++) {
        //    for (int y = 0; y < image1Height; y++) {
        //        if (image1.getRGB(x, y) != image2.getRGB(x, y)) {
        //            return false;
        //        }
        //    }
        //}

        return true;
    }

    public static BufferedImage[] getSlices(BufferedImage image, int sliceWidth, int sliceHeight) {
        final List<BufferedImage> slices = new ArrayList<>();
        final int imageWidth = image.getWidth();
        final int imageHeight = image.getHeight();

        for (int y = 0; y < imageHeight; y += sliceHeight) {
            for (int x = 0; x < imageWidth; x += sliceWidth) {

                int w = ((x + sliceWidth) < imageWidth) ?
                        sliceWidth : imageWidth - x;
                int h = ((y + sliceHeight) < imageHeight) ?
                        sliceHeight : imageHeight - y;

                BufferedImage slice = crop(image, x, y, w, h);
                slices.add(slice);
            }
        }

        return slices.toArray(new BufferedImage[0]);
    }

    public static ImageIcon loadIcon(URL image) {
        BufferedImage img = loadImage(image);
        return (img != null) ? new ImageIcon(img) : null;
    }

    public static BufferedImage loadImage(URL image) {
        try {
            return (image != null) ? ImageIO.read(image) : null;
        } catch (Exception ex) {
            LOGGER.error("Can't read image from '" + image + "'!", ex);
            return null;
        }
    }

    public static BufferedImage read(InputStream input) throws IOException {
        ImageReader reader = ImageIO.getImageReadersByFormatName("jpg").next();
        reader.setInput(ImageIO.createImageInputStream(input), false);
        //LOGGER.debug("number of images: " + reader.getNumImages(true));
        return reader.read(0);
    }

    public static BufferedImage resize(BufferedImage image, int maxWidth, int maxHeight) {
        return Scalr.resize(image, Scalr.Method.BALANCED, Scalr.Mode.BEST_FIT_BOTH, maxWidth, maxHeight);
    }

    public static BufferedImage toGrayScale(BufferedImage image) {
        BufferedImage result = new BufferedImage(
                image.getWidth(),
                image.getHeight(),
                BufferedImage.TYPE_BYTE_GRAY);
        Graphics2D g = (Graphics2D) result.getGraphics();
        g.drawImage(image, 0, 0, null);
        g.dispose();
        return result;
    }

    public static void write(BufferedImage image, OutputStream output, float compression) throws IOException {
        ImageWriter jpgWriter = ImageIO.getImageWritersByFormatName("jpg").next();
        ImageOutputStream jpgStream = ImageIO.createImageOutputStream(output);

        // Configure JPEG compression
        ImageWriteParam jpgWriteParam = jpgWriter.getDefaultWriteParam();
        jpgWriteParam.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
        jpgWriteParam.setCompressionQuality(compression);

        jpgWriter.setOutput(jpgStream);
        jpgWriter.write(null, new IIOImage(image, null, null), jpgWriteParam);
        jpgWriter.dispose();
        output.flush();
    }
}
