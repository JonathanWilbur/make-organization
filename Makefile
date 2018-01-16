all : ultimate_package penultimate_package

include configuration.make
include ./source/ultimate.make
include ./source/penultimate.make