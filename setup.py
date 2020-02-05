import os
import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()


with open(os.path.join("ralbot/uvmgen", "__about__.py")) as f:
    v_dict = {}
    exec(f.read(), v_dict)
    version = v_dict['__version__']

setuptools.setup(
    name="ralbot-uvm",
    version=version,
    author="Jude Zhang",
    author_email="564193687@qq.com",
    description="Generate UVM register model from compiled SystemRDL input",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/SystemRDL/RALBot-uvm",
    packages=['ralbot.uvmgen'],
    include_package_data=True,
    python_requires='>=3.4',
    install_requires=[
        "systemrdl-compiler>=1.5.0",
    ],
    classifiers=(
        "Development Status :: 5 - Production/Stable",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3 :: Only",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Operating System :: OS Independent",
        "Topic :: Scientific/Engineering :: Electronic Design Automation (EDA)",
    ),
    project_urls={
        #"Documentation": "TBD",
        "Source": "https://github.com/SystemRDL/RALBot-uvm",
        "Tracker": "https://github.com/SystemRDL/RALBot-uvm/issues"
    },
)
