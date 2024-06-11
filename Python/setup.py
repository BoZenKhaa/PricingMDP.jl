import setuptools
from setuptools import setup

setup(
        name='pricingmdprunner',
        version='0.0.1',
        description='MDPPricing runner',
        author='David Fiedler, Jan Mrkos',
        author_email='mrkosjan@gmail.com',
        license='MIT',
        packages=setuptools.find_packages(),
        install_requires=[
                'pyyaml',
        ],
        python_requires='>=3.8'
)

