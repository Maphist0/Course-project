"""
    QR code detector for extremely low quality input image

    Please install ZBar before using this code.

    See 'main.py' for the usage.

    Author:     Maphisto
    Version:    0.1
    Contact:    zhangz-z-p@sjtu.edu.cn
    License:    MIT
"""

from __init__ import *
from Util import *
from Decoder import *

class QRDetector():
    """ QR code detector for extreme condition
    """
    
    def __init__(self, DEBUG=False):
        """ Initializer of QRDetector class.
            
            Create a QR code decoder from ZBar.
        """

        """ The QR code decoder provided by ZBar
        """
        self.dc = Decoder()


        """ Set 'True' to show intermediate results
        """
        self.debug = DEBUG

        
        """ The dilation used when searching for candidate of 
                finder patterns

            Used in 'self.__find_qr_finder()'
        """
        self.dilation = 3


        """ The offset of y when finding finder patterns horizontally
         
            e.g.    Given a center location for y: y_c
                    With offset_y = 10, the code will search from
                    (y_c - 10) to (y_c + 10)

            Used in 'self.__locate_qr_horizontally_once()'
        """
        self.offset_y = 10

        
        """ The padding used when cropping the QR code from source image
            Do not set too large, 0 is the best
            
            Used in 'self.__crop_qr_region()'
        """
        self.pad = 0


        """ The configuration used in enhancing the cropped QR region
            Should be an odd number, like 37
            Change this value according to the type of QR code

            Used in 'self.__enhance_cropped_qr_region()'
        """
        self.length = 37


        """ The configuration used in enhancing the cropped QR region
            Provide a list for thresholds to test on

            Used in 'self.__enhance_cropped_qr_region()'
        """
        self.thres = np.arange(0.1, 1, 0.1)


        """ The configuration used in enhancing the cropped QR region
            Make the binary image larger to better calculate the grid size
                (avoid decimal numbers)

            Used in 'self.__enhance_cropped_qr_region()'
        """
        self.enlarge_ratio = 50


    def __open_file(self, fpath):
        """ Open an image file in PIL format and convert
                to opencv format.

            The opened file is stored in self.orig
            
            Mainly involves changing from [R G B] to [B G R]
        """

        pil = Image.open(fpath).convert('L')
        self.orig = pil_to_cv(pil)


    def __preprocess_img(self):
        """ Pre-process the input image, including:

            1. Convert to grayscale
            2. Median / Gaussian blur
            3. Adaptive thresholding
            4. Morphological transformation, 
                first 'close' then 'open'

            Sel 'self.debug' to 'True' to enable debugging information
        """
        
        ## Convert to grayscale
        self.gray = cv2.cvtColor(self.orig, cv2.COLOR_BGR2GRAY)

        ## Blur: median, Gaussian
        # gray = cv2.GaussianBlur(self.gray,(5,5),0)
        self.gray = cv2.medianBlur(self.gray, 5)

        ## Adaptive thresholding: 
        self.bw = cv2.adaptiveThreshold(self.gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,\
            cv2.THRESH_BINARY, 9, 2)
        self.bw_orig = 255 - self.bw
        self.bw = self.bw_orig

        ## Morphological transformation: erode, open
        self.kernel = np.ones((3, 3), np.uint8)
        self.bw_clear = cv2.morphologyEx(self.bw, cv2.MORPH_CLOSE, self.kernel)
        self.bw_clear = cv2.morphologyEx(self.bw_clear, cv2.MORPH_OPEN, self.kernel)
        # bw_clear = cv2.erode(bw, kernel, iterations=1)

        ## Prepare output
        self.bw = self.bw_clear


    def __cross_check_qr_region_horizontal(self, y_low, y_high, x_low, \
            x_high, y_length, y_center):

        ## Test the horizontal line goes across the center_y
        ##   satisfy 1:1:3:1:1 or not
        high_thres = 0.5
        low_thres = 0.5
        length_thres = 0.4
        x_high = x_low = x

        ## Find horizontally by refining x coordinate 
        ## To the lower side
        while x_low >= 0:
            if sum(self.bw[y_low:y_high, x_low+1])/255. > high_thres * y_length and \
                sum(self.bw[y_low:y_high, x_low])/255. < low_thres * y_length:
                break
            else:
                x_low -= 1
        ## To the higher side
        while x_high < self.bw.shape[1]:
            if sum(bw[y_low:y_high, x_high-1])/255. > high_thres * y_length and \
                sum(bw[y_low:y_high, x_high])/255. < low_thres * y_length:
                break
            else:
                x_high += 1

        return (x_low, x_high)

    def __cross_check_qr_region_filling(self, y_low, y_high, y_length, y_center):

        ## Find horizontally by filling the center white box, but failed
        ## Locate the center position
        while x_low >= 0 and self.bw[y_center, x_low] > 0:
            x_low -= 1
        
        ## Fill the center white box
        fill_y_up = fill_y_down = y_center
        while fill_y_up >= 0 and self.bw[fill_y_up, x_low] > 0:
            fill_y_up -= 1
        while fill_y_down <= self.bw.shape[0] and self.bw[fill_y_down, x_low] > 0:
            fill_y_down += 1
        # print y_center, fill_y_up, fill_y_down, x_low
        
        ## Fill the center white box
        bw_copy = self.bw.copy()
        bw_copy[fill_y_up:fill_y_down+1, x_low:x_low+fill_y_down-fill_y_up+1] = 255
        self.bw = bw_copy

        ## Visualize
        # cv2.rectangle(bw_copy,(x_low,fill_y_up), \
        #     (x_low+fill_y_down-fill_y_up+1,fill_y_down),(0,0,255),5)
        # cv2.imshow('bw_fill', bw_copy)
        # cv2.waitKey(0)


    def __cross_check_qr_region_hotizontal_ratio(self, y_low, y_high, \
            y_length, y_center):

        ## Find horizontally by searching for white and black intervals
        ##  but result is not good
    
        ## Left side:
        ## Center
        while x_low >= 0 and self.bw[y_center, x_low] > 0:
            x_low -= 1
        ## First black square
        while x_low >= 0 and self.bw[y_center, x_low] == 0:
            x_low -= 1
        # First white square
        while x_low >= 0 and self.bw[y_center, x_low] > 0:
            x_low -= 1

        ## Right side:
        ## Center
        while x_high >= 0 and self.bw[y_center, x_high] > 0:
            x_high += 1
        # First black square
        while x_high >= 0 and self.bw[y_center, x_high] == 0:
            x_high += 1
        # First white square
        while x_high >= 0 and self.bw[y_center, x_high] > 0:
            x_high += 1

        ## Check for inproper x length
        x_length = x_high - x_low + 1
        if (x_low == 0 or x_high == bw.shape[1]) or \
            abs(x_length - y_length) > y_length * length_thres:
            return (None, None)

        return (x_low, x_high)

    def __cross_check_qr_region_template(self, y_low, y_high, \
            x, y_length, y_center, module_width):

        ## Find hotizontally by matching the template
        ##
        ## Generate a template of the finder in QR code
        template = gen_qr_template(y_length, module_width)

        ## Iterate over all posible positions, find the best
        max_overlap = -1
        max_overlap_x = [0, 0]

        for offset in range(-3*module_width, 3*module_width+1):
        
            ## Calculated moved x coordinate
            x_low = x + offset - int(round(3.5*module_width))
            x_high = x_low + y_length

            ## Skip if out of bound
            if x_low < 0 or x_high >= self.bw.shape[1]:
                continue

            # print x_high - x_low, y_high - y_low
            # print y_low, y_high, x_low, x_high, bw_crop.shape

            ## Crop out the region
            bw_crop = self.bw[y_low:y_high, x_low:x_high]
            
            ## Calculate the overlap between pattern template
            sub = np.absolute(bw_crop - template) / 255
            overlap = 1 - np.sum(sub) / (y_length * y_length)

            ## Find the region with highest similarity
            if overlap > max_overlap:
                max_overlap_x = (x_low, x_high)
                max_overlap = overlap

            # if self.debug:
                # print overlap
                # tmp_vis = self.vis.copy()
                # cv2.rectangle(tmp_vis,(x_low,y_low),(x_high,y_high),(0,0,255),2)
                # cv2.imshow('template', tmp_vis)
                # cv2.waitKey(0)
        
        x_low, x_high = max_overlap_x
        return x_low, x_high, max_overlap

    def __cross_check_qr_region(self, width_state, x, y):

        ## Prepare for calculation
        y_length        = sum(width_state)
        y_low           = y - y_length
        y_high          = y
        y_center        = (y_low + y_high) / 2
        module_width    = int(round(y_length/7.))
        chosen_method   = 3  # see below for the meaning
        x_low = x_high  = max_overlap = 0

        ## RGB image for visualization
        vis = np.repeat(self.bw[:, :, np.newaxis], 3, axis=2)

        if chosen_method == 1:

            ## Method one, find horizontal line goes across the center_y 
            ## Works bad, not recommended, not maintained
            (x_low, x_high) = self.__cross_check_qr_region_horizontal( \
                y_low, y_high, y_length, y_center)
        
        elif chosen_method == 2:
        
            ## Method two, find a horizontal line which satisfies 1:1:3:1:1
            ## Works bad, not recommended, not maintained
            (x_low, x_high) = self.__cross_check_qr_region_hotizontal_ratio(\
                y_low, y_high, y_length, y_center)

        elif chosen_method == 3:

            ## Method three, cross check the region by matching a QR finder
            ##  pattern
            ## Works well, recomended
            (x_low, x_high, max_overlap) = self.__cross_check_qr_region_template(\
                y_low, y_high, x, y_length, y_center, module_width)

        else:
            pass

        return (x_low, x_high, max_overlap)

    def __check_qr_region(self, width_state, x, y):

        ## Total width vertically
        total = float(sum(width_state))
        ## The width of one bar
        module_width = total / 7
        ## The threshold to filter some results
        max_variance = module_width / 2
        width_ratio = [1, 1, 3, 1, 1]

        ## Test whether the current line follows 1:1:3:1:1 pattern
        result = True
        for i in range(5):
            result &= (abs(width_state[i] - width_ratio[i] * module_width)\
                < max_variance)

        ## Cross check to ensure more accuracy
        x_low = x_high = max_overlap = 0
        if result:
            (x_low, x_high, max_overlap) = self.__cross_check_qr_region(width_state, x, y)
            # print x, cross_check

        return (result, x_low, x_high, max_overlap)

    def __find_top2_regions(self, found_pos):
        """ Find top 2 regions of finder code in the candidate set
                'found_pos', only choose top 2 regions if the gap between
                highest and second is small enough.
            
            Otherwise only choose the highest one.

            The chosen boxes are stored in 'self.selected_pos'.
        """

        ## Find top 2 regions inside this candidate set
        selected_pos = []
        
        ## Extract the last value for overlapping
        overlaps = np.asarray(found_pos)[:,-1]
        
        ## Find the maximum overlapping position
        max_ov_id = np.argmax(overlaps)
        max_ov = overlaps[max_ov_id]
        max_x_center = (found_pos[max_ov_id][0] + found_pos[max_ov_id][1]) / 2
        max_x_size = found_pos[max_ov_id][0] - found_pos[max_ov_id][1]
        
        ## Reset the biggest overlap position
        overlaps[max_ov_id] = -1

        ## Find the second overlapping position
        second_ov_id = np.argmax(overlaps)
        second_ov = overlaps[second_ov_id]
        second_x_center = (found_pos[second_ov_id][0] + \
            found_pos[second_ov_id][1]) / 2
        overlaps[second_ov_id] = -1

        ## Avoid overlapping
        while max_x_center - second_x_center < 2 * max_x_size:
            second_ov_id = np.argmax(overlaps)
            second_ov = overlaps[second_ov_id]
            second_x_center = (found_pos[second_ov_id][0] + \
                found_pos[second_ov_id][1]) / 2
            overlaps[second_ov_id] = -1

        ## Soft maximum, only keep the top 2 regions if they have similar overlap
        selected_pos.append(found_pos[max_ov_id])
        if (max_ov - second_ov) / second_ov < 0.2:
            selected_pos.append(found_pos[second_ov_id])

        self.selected_pos = selected_pos


    def __locate_qr_horizontally_once(self, coordi, is_left=True):

        # Unpack coordination
        x_low, x_high, y_low, y_high = coordi

        h, w = self.bw.shape
        size = self.finder_size

        max_overlap = -1
        max_overlap_coordi = [0, 0]
        template = gen_qr_template(size, self.module_width)
        for x_offset in range(0, self.bw.shape[1]):
            for y_offset in range(-1*self.offset_y, self.offset_y):
                if is_left:
                    tmp_x = x_low - size - x_offset
                else:
                    tmp_x = x_high + size + x_offset

                tmp_y = y_low + y_offset
                if tmp_x < 0 or tmp_x + size >= w or \
                    tmp_y < 0 or tmp_y + size >= h:
                    break
                # print tmp_x, tmp_x+size, size
                bw_crop = self.bw[tmp_y:tmp_y+size, tmp_x:tmp_x+size]
                # print bw_crop.shape
                # print y_low, y_high, x_low, x_high, bw_crop.shape
                sub = np.absolute(bw_crop - template) / 255
                overlap = 1 - np.sum(sub) / (size * size)
                if overlap > max_overlap:
                    max_overlap = overlap
                    max_overlap_coordi = (y_low+y_offset, tmp_x)

        return max_overlap, max_overlap_coordi

    def __locate_qr_horizontally(self, coordi):
        """ Find finder patterns horizontally with a given coordination
        """

        # Find left and right
        max_overlap_l, max_overlap_coordi_l = self.__locate_qr_horizontally_once(
            coordi, True)
        max_overlap_r, max_overlap_coordi_r = self.__locate_qr_horizontally_once(
            coordi, False)

        # Find the higher one between left and right
        max_overlap = max(max_overlap_l, max_overlap_r)
        max_overlap_coordi = max_overlap_coordi_l if \
            (max_overlap_l > max_overlap_r) else max_overlap_coordi_r

        return max_overlap, max_overlap_coordi


    def __find_another_top_finder(self):
        """ Find another finder pattern on the upper side

            Process:
                1.  Find the qr finder region on the left and right side
                        between the first finder position

                2.  Choose the region with highest response
        """
        
        ## Find another corner horizontally
        pos = self.selected_pos[0]
        self.finder_size = pos[2] - pos[1] + 1

        ## If two finder regions are found, no need to find another
        ##   finder on the top side
        if len(self.selected_pos) == 1:

            self.module_width = int(round(self.finder_size/7.))
            
            (_, max_overlap_coordi) = self.__locate_qr_horizontally(pos[1:5])

            x_low = max_overlap_coordi[1]
            x_high = max_overlap_coordi[1] + self.finder_size
            y_low = max_overlap_coordi[0]
            y_high = max_overlap_coordi[0] + self.finder_size

            ## Append to the selected position for finder pattern
            self.selected_pos.append((0, x_low, x_high, y_low, y_high, 0))


    def __find_bottom_finder(self):
        """ Find the last finder pattern on the bottom of QR code region
        """

        ## Find the last corner vertically
        ## Set the search point to bottom-center
        selected_pos_np = np.asarray(self.selected_pos)
        qr_size = abs(selected_pos_np[0,1] - selected_pos_np[1,1])
        bottom_center = np.mean(selected_pos_np[:, 1:5], axis=0)
        bottom_center = np.round(bottom_center).astype(int)
        bottom_center[2:4] += np.asarray([qr_size, qr_size], dtype=int)

        ## Find the finder pattern from the botton-center point
        (_, max_overlap_coordi) = self.__locate_qr_horizontally(bottom_center)

        x_low = max_overlap_coordi[1]
        x_high = max_overlap_coordi[1] + self.finder_size
        y_low = max_overlap_coordi[0]
        y_high = max_overlap_coordi[0] + self.finder_size
        
        ## Append to the selected position for finder pattern
        self.selected_pos.append((0, x_low, x_high, y_low, y_high, 0))


    def __find_qr_finder(self):
        """ Find all three finders in a given image

            Process:
                1.  For all vertical lines in the image, find
                        a sub-line which has a pattern of 
                        (black - B, white - W)
                                [B W B W B]

                2.  Test for this sub-line. See whether it follows
                            [1 : 1 : 3 : 1 : 1]

                3.  Save all these sub-lines, use a QR finder template to test
                        some regions around it. 
                    See whether there is a high response of QR finder.

                4.  Locate other two or three finder patterns by searching
                        and matching of QR finder template

            TODO: Add support for cases that the image is rotated
        """

        ## Prepare
        h, w = self.bw.shape
        found_pos = []

        """ Locate the qrcode area

            The color:                    
                                        W   B   W   B   W
            The ratio of each color:
                                        1 : 1 : 3 : 1 : 1
            The state code for each state:
                                    0   1   2   3   4   5   6
        """
        for x in xrange(0, w, self.dilation):
            
            ## State code
            state = 0
            ## Number of pixels with the same color in current state
            width_state = [0 for _ in range(5)]

            for y in xrange(h):
                
                ## If the color has changed (black to white OR white to black)
                if (self.bw[y, x] and state % 2 == 0) or \
                    (self.bw[y, x] == 0 and state % 2 == 1):
                    state += 1

                ## Save the size of current color
                if state != 0 and state != 6:
                    width_state[state-1] += 1

                ## End of check area
                if state == 6:
                    (result, x_low, x_high, max_overlap) = \
                        self.__check_qr_region(width_state, x, y)

                    if result:
                        
                        ## Found the proper 1:1:3:1:1 region
                        ## Append to a candidate list
                        state = 0
                        found_pos.append((x, x_low, x_high, \
                            y-sum(width_state), y, max_overlap))
                        for i in range(5):
                            width_state[i] = 0

                    else:

                        # Failed to find the 1:1:3:1:1 region
                        # Move the counting array one position to the left
                        # Prepare for next checking
                        state = 4
                        for i in range(3):
                            width_state[i] = width_state[i+1]
                        width_state[3] = 1
                        width_state[4] = 0

        ## A candidate set of regions containing finder regions has been
        ##   stored in 'found_pos'

        ## Find the top 2 regions of finder pattern if possible
        self.__find_top2_regions(found_pos)

        ## Find another one or two finder pattern
        self.__find_another_top_finder()
        self.__find_bottom_finder()


    def __crop_qr_region(self):
        """ Crop out the region of QR code as the new testing image.
        """
        
        ## Calculate the outer bound
        selected_pos_np = np.asarray(self.selected_pos, dtype=int)
        left_most = np.amin(selected_pos_np[:, 1])
        right_most = np.amax(selected_pos_np[:, 2])
        up_most = np.amin(selected_pos_np[:, 3])
        bottom_most = np.amax(selected_pos_np[:, 4])

        ## Crop the original image
        self.extracted_qr_img = self.orig[up_most-self.pad:bottom_most+self.pad,\
            left_most-self.pad:right_most+self.pad, :]


    def __threshold_two_class(self, im):
        """ Threshold the image according to its histogram

            This function assumes that only two classes will be return

            Done by finding two peaks from the histogram of Y in YUV format
        """

        def rounded_y_color(y):
            rounded = int(round(y))
            rounded = max(rounded, 0)
            rounded = min(rounded, 255)
            return rounded

        h, w, _ = im.shape
        yuv = rgb_to_yuv(im)
        # print yuv.shape, h, w

        # Calculate Y histogram
        bin_y = np.zeros([256])
        
        for y in range(h):
            for x in range(w):

                rounded = rounded_y_color(yuv[y, x, 0])
                bin_y[rounded] += 1
        
        # plt.plot(bin_y)
        # plt.show()
        
        # Find top two Y values
        color_1 = np.argmax(bin_y)

        for offset in range(-50, 50):

            ## Avoid out of bound
            idx = min(color_1+offset, 255)
            idx = max(idx, 0)
            bin_y[idx] = 0
        
        color_2 = np.argmax(bin_y)
        # print color_1, color_2

        # Binarize in pixel level
        bw = np.zeros([h, w])

        for y in range(h):
            for x in range(w):
        
                rounded = rounded_y_color(yuv[y, x, 0])
        
                if abs(rounded - color_1) < abs(rounded - color_2):
                    bw[y, x] = 255
                else:
                    bw[y, x] = 0

        return bw


    def __realign_grid(self, bw, module_width, length):
        """ Re-align the grid mesh on the binary QR code region

            Based on slightly shift the grid position and grid size

            Find the best combination which maximize the response of 
                applying a template according to three finder pattern
                of QR code.
        """

        ## Setup the shift ranges and stepsizes
        moving_max = int(0.2*module_width)
        moving_stepsize = int(0.1*moving_max)
        resize_max = int(0.05*module_width)
        resize_stepsize = int(0.5*resize_max)
        h, w = bw.shape

        ## Generate a list of points for check point
        ## These points comes from three finder patterns
        idx_check_box = gen_check_box_idx()

        ## Move the grid a little bit each time to 
        ##   find the highest coverage region
        max_cnt = -1
        max_xys = (0, 0, module_width)

        ## For each grid size
        for resize in range(-1*resize_max, resize_max, resize_stepsize):
            
            tmp_module_width = module_width + resize

            ## Avoid size being too large
            if length * tmp_module_width > h or \
                length * tmp_module_width > w:
                break

            ## For each shift in both x and y axises
            for mov_y in range(-1*moving_max, moving_max, moving_stepsize):
                for mov_x in range(-1*moving_max, moving_max, moving_stepsize):


                    ## Get the total number of points inside each box covered by
                    ##   check points
                    cnt = 0

                    for idx in idx_check_box:
                    
                        ## Give penalty if the box is out of bound
                        penalty_y = 1
                        penalty_x = 1

                        y_low = mov_y + idx[0] * tmp_module_width
                        y_high = mov_y + (idx[0] + 1) * tmp_module_width
                        x_low = mov_x + idx[1] * tmp_module_width
                        x_high = mov_x + (idx[1] + 1) * tmp_module_width

                        ## Avoid index out of bound,
                        ##   if so, add up to penalty
                        if y_low < 0:
                            penalty_y += 0 - y_low
                            y_low = 0
                        if y_high >= h:
                            penalty_y += y_high - h
                            y_high = h - 1
                        if x_low < 0:
                            penalty_x += 0 - x_low
                            x_low = 0
                        if x_high >= w:
                            penalty_x += x_high - w
                            x_high = w - 1

                        ## Sum up the number of points
                        cnt += np.sum(255-bw[y_low:y_high, x_low:x_high]) / 255

                        ## Consider the penalty
                        cnt -= penalty_x * penalty_y

                    ## Look for the combination with the highest response
                    if cnt > max_cnt:
                        max_cnt = cnt
                        max_xy = (mov_y, mov_x, resize)

        return max_xy


    def __enhance_cropped_qr_region(self):
        """ Apply an griding algorithm to the cropped QR code image
        """

        ## Re-calculate the module width with an enlarged binary image
        module_width = np.round(self.enlarge_ratio * self.extracted_qr_img.shape[0] \
            / float(self.length)).astype(int)

        ## Make a backup of cropped QR image
        data = self.extracted_qr_img.copy()
        
        """ Two ways here to binarize the QR region

            1. Use a histogram based two class thresholding method

            2. use adaptive thresholding method

            My personal experience suggests that the first method works better
        """
        if 1:
            bw = self.__threshold_two_class(data)
        else:
            gray = cv2.cvtColor(data, cv2.COLOR_BGR2GRAY)
            bw = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,\
                cv2.THRESH_BINARY, 9, 2)
        
        ## Prepare the image
        ## Resize the image to a square
        h, w = bw.shape
        larger_axis = h if h > w else w
        h = w = larger_axis * self.enlarge_ratio
        bw_larger = cv2.resize(bw, (h, w))

        ## Re-align the grid
        offset = self.__realign_grid(bw_larger, module_width, self.length)
        mov_y, mov_x, resize = offset
        module_width = module_width + resize
        # print offset

        ## Generate the enhanced map
        enhanced = np.zeros([self.length, self.length, self.thres.shape[0]])
        
        ## For visualization
        vis = np.repeat(bw_larger[:, :, np.newaxis], 3, axis=2)
        
        for y in range(self.length):
            for x in range(self.length):
                
                ## Calculate the coordination in each grid
                y_low = max(mov_y + y * module_width, 0)
                y_high = min(mov_y + (y + 1) * module_width, h)
                x_low = max(mov_x + x * module_width, 0)
                x_high = min(mov_x + (x + 1) * module_width, w)

                ## Size of each grid
                s_xy = (y_high - y_low) * (x_high - x_low)

                ## Sum up all pixels in each grid
                sum_bw = np.sum(bw_larger[y_low:y_high, x_low:x_high]) / 255.

                ## For visualization
                cv2.rectangle(vis, (x_low,y_low), (x_high,y_high), (0,0,255), 6)
                
                ## For each threshold, generate a different enhanced map
                for j in range(self.thres.shape[0]):
                    
                    label = (sum_bw > (self.thres[j] * s_xy)).astype(int)
                    enhanced[y, x, j] = label

        ## Save the result for visualization
        self.enlarged_qr_region_with_grid = vis

        ## Save the enhanced images
        self.enhanced = enhanced

    def __test_enhanced_images(self):
        """ Test the enhanced images with multiple thresholds
        """

        ## Test for all possible cases with different threshold
        self.final_qr_region = None
        num_thres = self.enhanced.shape[2]

        for i in range(num_thres):
        
            pic = self.enhanced[:,:,i]
            result = self.dc.decode(cv_to_pil(pic))
            
            if result:
                self.final_qr_region = pic
                return result

        return None


    def __visualize(self, state):
        """ Visualize intermediate results in each step
        """

        ## Visualize
        if self.debug:

            if state == 1:
                pass

                ## Show the image while doing pre-processing
                # titles = ['Original Image', 'Grayscale + blur',
                #     'Adaptive Thresholding', 'Thresholding + erode/open']
                # images = [self.orig, self.gray, self.bw_orig, self.bw_clear]
                # for i in xrange(4):
                #     plt.subplot(2, 2, i+1)
                #     plt.imshow(images[i], 'gray')
                #     plt.title(titles[i])
                #     plt.xticks([])
                #     plt.yticks([])
                # plt.show()

            elif state == 2:

                ## Show the three QR finder box in the source image
                vis = self.orig.copy()
                for _, x_low, x_high, y_low, y_high, _ in self.selected_pos:
                    cv2.rectangle(vis, (x_low,y_low), (x_high,y_high),\
                        (0,0,255), 2)
                cv2.imshow('QR code with finder', vis)
                if cv2.waitKey(0) == 9:
                    cv2.destroyAllWindows()

            elif state == 3:

                ## Show the cropped QR code region from the source image
                cv2.imshow('Cropped qr code', self.extracted_qr_img)
                if cv2.waitKey(0) == 9:
                    cv2.destroyAllWindows()

            elif state == 4:

                ## Show the enlarged QR region with grid
                cv2.imwrite('tmp-1.jpg', self.enlarged_qr_region_with_grid)

                ## Show the binarize map with different threshold
                titles = [str(i) for i in self.thres]
                images = self.enhanced
                for i in xrange(min(4, images.shape[2])):
                    plt.subplot(3, 3, i+1)
                    plt.imshow(images[:,:,i], 'gray')
                    plt.title(titles[i])
                    plt.xticks([])
                    plt.yticks([])
                plt.show()

            else:
                pass


    def detect(self, fpath):
        
        print '\nTesting file: ', fpath

        self.__open_file(fpath)
        self.__preprocess_img()
        print '[1/5] Done preprocess source image ......'
        self.__visualize(1)


        self.__find_qr_finder()
        print '[2/5] Done finding qr finder ......'
        self.__visualize(2)


        self.__crop_qr_region()
        print '[3/5] Done finding qr region ......'
        self.__visualize(3)


        ## Try to decode the cropped image directly
        result = self.dc.decode(cv_to_pil(self.extracted_qr_img))
        # print result
        
        if not result: 
            
            print '[4/5] Enhancing the cropped QR region, please be patient ......'
            self.__enhance_cropped_qr_region()
            print '[4/5] Done enhancing the cropped QR region ......'
            self.__visualize(4)

            ## Re-test the enhanced image
            result = self.__test_enhanced_images()


        if result:
            print '[5/5] Successfully decode the QR code: '
            print result
        else:
            print '[5/5] Failed to decode the QR code ......'

        return result


        

        

