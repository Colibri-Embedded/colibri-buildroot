#!/usr/bin/env python

# Author: Daniel Kesler (kesler.daniel@gmail.com)

# Python 2 and 3:
from __future__ import print_function    # (at top of module)
from six.moves import input
import os, sys
import jinja2

makefile_py_template='''################################################################################
#
# {{pkg_name}}
#
################################################################################

{{pkg_name_ucase}}_VERSION = {{pkg_version}}
{{pkg_name_ucase}}_SOURCE = $({{pkg_name_ucase}}_VERSION).tar.gz
{{pkg_name_ucase}}_SITE = # add website here #
{{pkg_name_ucase}}_LICENSE = MIT
{{pkg_name_ucase}}_LICENSE_FILES = LICENSE
{{pkg_name_ucase}}_SETUP_TYPE = setuptools
#{{pkg_name_ucase}}_DEPENDENCIES = 

$(eval $(python-package))

'''

makefile_autotools_template='''################################################################################
#
# {{pkg_name}}
#
################################################################################

{{pkg_name_ucase}}_VERSION = {{pkg_version}}
{{pkg_name_ucase}}_SOURCE = $({{pkg_name_ucase}}_VERSION).tar.gz
{{pkg_name_ucase}}_SITE = # add website here #
{{pkg_name_ucase}}_LICENSE = 
{{pkg_name_ucase}}_LICENSE_FILES = 
#{{pkg_name_ucase}}_DEPENDENCIES = 

$(eval $(autotools-package))

'''

makefile_cmake_template='''################################################################################
#
# {{pkg_name}}
#
################################################################################

{{pkg_name_ucase}}_VERSION = {{pkg_version}}
{{pkg_name_ucase}}_SOURCE = $({{pkg_name_ucase}}_VERSION).tar.gz
{{pkg_name_ucase}}_SITE = # add website here #
{{pkg_name_ucase}}_LICENSE = 
{{pkg_name_ucase}}_LICENSE_FILES = 
#{{pkg_name_ucase}}_DEPENDENCIES = 
#{{pkg_name_ucase}}_INSTALL_STAGING = YES

$(eval $(cmake-package))

'''

config_in_template='''config BR2_PACKAGE_{{pkg_name_ucase}}
	bool "{{pkg_name}}"
	help
	  Add some help text

	  Add the homepage url
'''

templateLoader = jinja2.DictLoader({
	'Config.in': config_in_template,
	'python.mk': makefile_py_template,
	'autotools.mk': makefile_autotools_template,
	'cmake.mk': makefile_cmake_template,
})
templateEnv = jinja2.Environment( loader=templateLoader )

def create_from_template(template, output, env = {}, overwrite = True):
	if not os.path.exists(output) or overwrite:
		t = templateEnv.get_template(template)
		if 'filename' not in env:
			env['filename'] = os.path.basename(output)
		outputText = t.render( env )
		if output:
			f = open(output, 'w')
			f.write(outputText)
			f.close()
			print("create '{:s}' based on '{:s}'".format(output,template))
		else:
			print("create based on '{:s}'".format(template))
			print(outputText)

def create_dir(f):
	if not os.path.exists(f):
		os.makedirs(f)
		print( 'mkdir {:s}'.format(f) )

def create_link(src, dst, overwrite = False):
	if os.path.lexists(dst):
		if overwrite:
			os.remove(dst)
			os.symlink(src, dst)
			print( 'softlink {:s} -> {:s}'.format(dst,src) )
	else:
		os.symlink(src, dst)
		print( 'softlink {:s} -> {:s}'.format(dst,src) )

def usage():
	print('You must provide a command.')
	print('  package [python]')
	exit()

def generate_python_package():
	# Package name
	pkg_name = input("Package name (python-newpackage): " )
	if not pkg_name:
		print("No package name provided. Exiting...")
		exit()

	# Package name
	pkg_version = input("Package version (1.0.0): " )
	if not pkg_version:
		pkg_version = '1.0.0'

	params = {
		"pkg_name" : pkg_name,
		"pkg_name_ucase" : pkg_name.upper().replace('-','_'),
		"pkg_version" : pkg_version
	}

	create_dir(pkg_name)
	create_from_template('Config.in', os.path.join(pkg_name,'Config.in'), params)
	create_from_template('python.mk', os.path.join(pkg_name,pkg_name+'.mk'), params)
	
def generate_cmake_package():
	# Package name
	pkg_name = input("Package name (newpackage): " )
	if not pkg_name:
		print("No package name provided. Exiting...")
		exit()

	# Package name
	pkg_version = input("Package version (1.0.0): " )
	if not pkg_version:
		pkg_version = '1.0.0'

	params = {
		"pkg_name" : pkg_name,
		"pkg_name_ucase" : pkg_name.upper().replace('-','_'),
		"pkg_version" : pkg_version
	}

	create_dir(pkg_name)
	create_from_template('Config.in', os.path.join(pkg_name,'Config.in'), params)
	create_from_template('cmake.mk', os.path.join(pkg_name,pkg_name+'.mk'), params)

def generate_autotools_package():
	# Package name
	pkg_name = input("Package name (newpackage): " )
	if not pkg_name:
		print("No package name provided. Exiting...")
		exit()

	# Package name
	pkg_version = input("Package version (1.0.0): " )
	if not pkg_version:
		pkg_version = '1.0.0'

	params = {
		"pkg_name" : pkg_name,
		"pkg_name_ucase" : pkg_name.upper().replace('-','_'),
		"pkg_version" : pkg_version
	}

	create_dir(pkg_name)
	create_from_template('Config.in', os.path.join(pkg_name,'Config.in'), params)
	create_from_template('autotools.mk', os.path.join(pkg_name,pkg_name+'.mk'), params)

commands = {
	'package' : {
		'python' : generate_python_package,
		'autotools' : generate_autotools_package,
		'cmake' : generate_cmake_package,
	}
}

if __name__ == '__main__':
	if len(sys.argv) < 2:
		usage()
		
	if sys.argv[1] in commands:
		if sys.argv[2] in commands[sys.argv[1]]:
			commands[sys.argv[1]][sys.argv[2]]()
		else:
			usage()
	else:
		usage()

