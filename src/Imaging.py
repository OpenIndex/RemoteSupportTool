#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2015 OpenIndex.de
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

__author__ = 'Andreas Rudolph'

from PIL import Image
from PIL.ImageTk import PhotoImage
from src import OS_DARWIN

#if OS_WINDOWS or OS_DARWIN:
#    from PIL.ImageTk import PhotoImage
#else:
#    from Tkinter import PhotoImage


if OS_DARWIN:

    def alpha_composite(front, back):
        """Alpha composite two RGBA images.

        Source: http://stackoverflow.com/a/9166671/284318

        Keyword Arguments:
        front -- PIL RGBA Image object
        back -- PIL RGBA Image object
        """
        #return Image.alpha_composite(front, back)
        import numpy

        front = numpy.asarray(front)
        back = numpy.asarray(back)
        result = numpy.empty(front.shape, dtype='float')
        alpha = numpy.index_exp[:, :, 3:]
        rgb = numpy.index_exp[:, :, :3]
        falpha = front[alpha] / 255.0
        balpha = back[alpha] / 255.0
        result[alpha] = falpha + balpha * (1 - falpha)
        old_setting = numpy.seterr(invalid='ignore')
        result[rgb] = (front[rgb] * falpha + back[rgb] * balpha * (1 - falpha)) / result[alpha]
        numpy.seterr(**old_setting)
        result[alpha] *= 255
        numpy.clip(result, 0, 255)
        # astype('uint8') maps np.nan and np.inf to 0
        result = result.astype('uint8')
        result = Image.fromarray(result, 'RGBA')
        return result


    def alpha_composite_with_color(image, color=(255, 255, 255)):
        """Alpha composite an RGBA image with a single color image of the
        specified color and the same size as the original image.

        Keyword Arguments:
        image -- PIL RGBA Image object
        color -- Tuple r, g, b (default 255, 255, 255)

        """
        back = Image.new('RGBA', size=image.size, color=color + (255,))
        return alpha_composite(image, back)


def open_image(path, bgcolor=(255, 255, 255)):
    img = Image.open(path)

    # OS X does not render images alpha channel correctly.
    # Therefore alpha channels are converted.
    # See http://stackoverflow.com/q/9166400 for more details about the mechanism.
    if OS_DARWIN and img.mode == 'RGBA':
        img = alpha_composite_with_color(img, bgcolor)

    return img


def open_photoimage(path, bgcolor=(255, 255, 255)):
    img = open_image(path, bgcolor=bgcolor)
    return PhotoImage(image=img)
