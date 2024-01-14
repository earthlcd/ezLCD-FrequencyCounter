### ezLCD-Frequency Counter Example Program
This program demonstrates how to use the ezLCD-5035 to read the frequency of a digital signal on a pin that supports interrupts.

Tested from sub 1 Hz to 32kHz

![IMG_2237](https://github.com/earthlcd/ezLCD-FrequencyCounter/assets/198251/14dd046d-1723-4f4a-bfc6-4039614940ca)


Testing this application against measurements on an oscilliscope I got "real" measurement.  The scope was last calibrated at the factory over 7 years ago so take these measuremnts with a grain of salt.  
I can see that the application is measuring within less than 1% of my scope for frequencies less than 150 Hz.  Above 150 Hz the error is greater (probably due to execution time of the lua script).  The error between the set freq and the scope is probably due to how I'm generating the square wave.  That is to say I'm using a PiPico in a loop which has overhead that is not seen at the lower frequencies.

| Set Freq Hz	| Scope | ezLCD-5035 | %err |
| ----------	| ----- | ---------- | ---- |
| 100 | 99.9 | 99.7 | 0.20% |
| 150 | 149 | 148.36 | 0.43% |
| 200 | 199 | 196.21 | 1.40% |
| 250 | 249 | 242.5 | 2.61% |
| 500 | 495 | 474.16 | 4.21% |
| 1000 | 982 | 931.02 | 5.19% |
| 2000 | 1930 | 1783.39 | 7.60% |
| 4000 | 3770 | 3438.31 | 8.80% |
| 8000 | 7120 | 6667.07 | 6.36% |
| 16000 | 12800 | 11707 | 8.54% |
| 32000 | 21500 | 20213 | 5.99% |
| 64000 | 33300 | 22975 | 31.01% |


