![Logo][https://github.com/macandyp/CSVToXLIFF/blob/master/CSVToXLIFF/Assets.xcassets/AppIcon.appiconset/Icon_128x128%402x.png]
# CSVToXLIFF

While there are many XLIFF applications available, there was a very unique scenario that occured within my company: nobody had permission to install any external applications on their Windows machines. They did, however, all have Excel. This application does two things:

1. Takes an XLIFF file and converts it to a barebones CSV file. It includes the source, target, and note fields from XLIFF.
2. Once translations are placed in the CSV file, you can then convert it **back** to the XLIFF file. This is done in two steps: 
    1. Select the original XLIFF file
    2. Select the CSV file

There is quite a bit of work that is needed on the application, but it generally works.

## Needed
- [ ] Better UI/flow for importing CSV for XLIFF conversion
- [ ] Handle commas better in original text strings