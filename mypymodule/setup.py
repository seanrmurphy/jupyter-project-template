from setuptools import setup, find_packages
setup(
    name='mypymodule',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        # List packages and versions you depend on.
        # 'scikit-learn==0.21.3',
    ],
    extras_require={
        # Best practice to list non-essential dev dependencies here.
        'dev': [
            'flake8==3.7.9',
            'pytest==5.2.2',
            'pytest-cov==2.8.1',
        ]
    }
)
