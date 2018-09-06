""" A simple script to look at FoMo RenderCubes. OLD: Wavelengths are mapped entirely into blue, green or red depending on their size (the spectrum is divided into three equal parts). """

import sys
from pylab import zeros, close, imshow, show, title
from math import sqrt
import matplotlib.cm as cm
import matplotlib.pyplot as pl

def show_cube(path):
	
	# Load input file
	with open(path, "r") as f:
		lines = f.readlines()
	
	# Initialize grid
	x_pixels = 50#149/50
	y_pixels = 724#148/724
	grid = zeros([y_pixels, x_pixels])
	
	ys = set()
	
	# Read header
	amount = int(lines[1])
	
	# Find bounds
	MAX_VALUE = 10**20
	minx, maxx = MAX_VALUE, -MAX_VALUE
	miny, maxy = MAX_VALUE, -MAX_VALUE
	minl, maxl = MAX_VALUE, -MAX_VALUE
	for line in lines[5:]:
		words = line.split(" ")
		x = float(words[0])
		y = float(words[1])
		l = float(words[2])
		minx, maxx = min(minx, x), max(maxx, x)
		miny, maxy = min(miny, y), max(maxy, y)
		minl, maxl = min(minl, l), max(maxl, l)
	
	# Map to pixels and add emissivity
	x_distance = maxx - minx
	y_distance = maxy - miny
	for line in lines[5:]:
		words = line.split(" ")
		l = float(words[2])
		x = int(round((float(words[0]) - minx)/x_distance*(x_pixels - 1)))
		y = int(round((float(words[1]) - miny)/y_distance*(y_pixels - 1)))
		grid[y, x] += float(words[3])
	
	print("Finished loading!")
	
	# Display grid
	half_x_pixel = x_distance/(x_pixels - 1)/2
	half_y_pixel = y_distance/(y_pixels - 1)/2
	close('all')
	imshow(grid, extent=(minx - half_x_pixel, maxx + half_x_pixel, miny - half_y_pixel, maxy + half_y_pixel), vmin=0, cmap=cm.hot, aspect="auto")
	cb = pl.colorbar()
	cb.set_label(r'$ergs\ cm^{-2} s^{-1} sr^{-1}$')
	title(path)
	show()

def compare_cubes(path1, path2):
	
	cubes = []
	
	# Read input
	for path in path1, path2:
		
		# Load input file
		with open(path, "r") as f:
			lines = f.readlines()
		
		# Initialize grid
		x_pixels = 149
		y_pixels = 148
		l_pixels = 100
		grid = zeros([x_pixels, y_pixels, l_pixels])
		
		# Read header
		amount = int(lines[1])
		
		# Find bounds
		minx, maxx = x_pixels, 0
		miny, maxy = y_pixels, 0
		minl, maxl = 1000, 0
		for line in lines[5:]:
			words = line.split(" ")
			x = float(words[0])
			y = float(words[1])
			l = float(words[2])
			minx, maxx = min(minx, x), max(maxx, x)
			miny, maxy = min(miny, y), max(maxy, y)
			minl, maxl = min(minl, l), max(maxl, l)
		
		# Map to pixels and add emissivity
		x_distance = maxx - minx
		y_distance = maxy - miny
		l_distance = maxl - minl
		for line in lines[5:1000]:
			words = line.split(" ")
			x = int(round((float(words[0]) - minx)/x_distance*(x_pixels - 1)))
			y = int(round((float(words[1]) - miny)/y_distance*(y_pixels - 1)))
			l = int(round((float(words[2]) - minl)/l_distance*(l_pixels - 1)))
			grid[x, y, l] = float(words[3])
		
		cubes.append(grid)
	
	#cubes[1] = cubes[1]/16.5990192
	
	# Compare cubes
	mean0 = cubes[0].mean()
	print("mean(0):", mean0)
	mean1 = cubes[0].mean()
	print("mean(1):", mean1)
	rmse = sqrt(((cubes[0] - cubes[1])**2).mean())
	print("RMSE(0-1):", rmse)
	print("RMSE(0-1)/mean(0):", rmse/mean0)
	print("RMSE(0-1)/mean(1):", rmse/mean1)
	print(cubes[1]/cubes[0])

def main():
	
	# Load input file
	if len(sys.argv) == 3 and sys.argv[1] == "--show":
		show_cube(sys.argv[2])
	elif len(sys.argv) == 4 and sys.argv[1] == "--compare":
		compare_cubes(sys.argv[2], sys.argv[3])
	else:
		print("Usage: python3 analyze_render_cube.py --show <render_cube_txt> OR python3 analyze_render_cube.py --compare <render_cube1_txt> <render_cube2_txt>")
		return

main()