from setuptools import setup, find_packages

requirements = [
    'SQLAlchemy==1.4.17',
    'aiofiles==0.7.0',
    'fastapi==0.65.2',
    'psycopg2',
    'pydantic==1.8.2',
    'starlette==0.14.2',
    'uvicorn==0.13.4',
]

setup(name="quipper",
      install_requires=requirements,
      packages=find_packages())
