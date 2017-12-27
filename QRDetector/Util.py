"""
    QR code detector for extremely low quality input image

    Please install ZBar before using this code.

    See 'main.py' for the usage.

    Author:     Maphisto
    Version:    0.1
    Contact:    zzp201501@gmail.com
    License:    MIT
"""

from __init__ import *
from Decoder import Decoder

def test_folder(folder):
    """ Test all images inside a folder

        Use Zbar library to test the image.

    Args:
        folder:  The path of your target folder

    Returns:
        (succ, fail, rate):  The number of success, failure, 
        and the "success rate" = (succ) / (succ + fail)

    """

    def is_img(path):
        # Add more extensions if you need
        img_ext = ['jpg', 'png', 'bmp']
        return path.split('.')[-1] in img_ext

    dc = Decoder()
    for root, folders, files in os.walk(folder):
        img_list = [os.path.join(root, file) for file in files if is_img(file)]

    succ = fail = 0
    for img in img_list:
        pil = Image.open(img).convert('L')
        code = dc.decode(pil)
        if len(code) > 0:
            succ += 1
        else:
            fail += 1
    rate = float(succ) / (succ + fail)
    return (succ, fail, rate)


def pil_to_cv(pil):
    """ Convert an image loaded from PIL to opencv format

        The main difference is that PIL uses [R, G, B] and opencv uses
            [B, G, R].

    Args:
        pil:  An image loaded from PIL function

    Returns:
        cv_img:  The corresponding image in opencv format

    """
    pil_img = pil.convert('RGB')
    cv_img = np.array(pil_img)
    # Convert RGB to BGR
    cv_img = cv_img[:,:,::-1].copy()
    return cv_img


def cv_to_pil(cv):
    """
    """
    cv2.imwrite('tmp.jpg', cv)
    pil_img = Image.open('tmp.jpg').convert('L')
    return pil_img


def gen_qr_template(size, margin):
    """ Generate a square template for three corners in QR-code

    Args:
        size:  The width of template kernel
        margin:  1/7 of the width of template kernel,
            recommend using int(round(size/7.)) to pass in

    Returns:
        template:  a "size x size" numpy matrix following the 
        definition of QR-code

    """
    template = np.zeros([size, size])
    template += 255
    template[margin:size-margin, margin:size-margin] = 0
    template[2*margin:size-2*margin, 2*margin:size-2*margin] = 255
    return template


def gen_check_box_idx():
    """ Generate a list containing the coordinate of three
            finder patterns in QR-code

    Args:
        None

    Returns:
        idx_check_box:  a list containing the coordinate each pixel 
        of the three finder patterns

    """

    idx_check_box = []
    for i in range(7):
        idx_check_box.append((0, i))
        idx_check_box.append((6, i))
        idx_check_box.append((30, i))
        idx_check_box.append((36, i))
        idx_check_box.append((0, 30+i))
        idx_check_box.append((6, 30+i))
    for i in range(1, 6):
        idx_check_box.append((i, 0))
        idx_check_box.append((i, 6))
        idx_check_box.append((i, 30))
        idx_check_box.append((i, 36))
        idx_check_box.append((30+i, 0))
        idx_check_box.append((30+i, 6))
    for i in range(3):
        for j in range(3):
            idx_check_box.append((2+i, 2+j))
            idx_check_box.append((32+i, 2+j))
            idx_check_box.append((2+i, 32+j))
    return idx_check_box


def rgb_to_yuv(rgb):
    """ Convert image with RGB format to YUV format

    Args:
        rgb:  An image in RGB format

    Returns:
        yuv:  The image in YUV format

    """
      
    m = np.array([[ 0.29900, -0.16874,  0.50000],
                 [0.58700, -0.33126, -0.41869],
                 [ 0.11400, 0.50000, -0.08131]])
      
    yuv = np.dot(rgb,m)
    yuv[:,:,1:]+=128.0
    return yuv