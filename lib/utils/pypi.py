from urllib.request import urlopen
from bs4 import BeautifulSoup


class PyPIWeb(object):
    def __init__(self) -> None:
        self.URL: str = 'https://pypi.org/search'
        self.NAME_CLASS: str = 'package-snippet__name'
        self.VERSION_CLASS: str = 'package-snippet__version'
        self.PACKAGE_CLASS: str = 'package-snippet__description'

    def search(self, keyword: str) -> list:
        _url = f'{self.URL}/?q={keyword}'
        print(_url)
        page = urlopen(_url)
        html_bytes = page.read()
        raw_html = html_bytes.decode('utf-8')
        html = BeautifulSoup(raw_html)

        packages: list = html.find_all(
            ['span', 'p'],
            {'class': [
                self.NAME_CLASS,
                self.VERSION_CLASS,
                self.PACKAGE_CLASS,
            ]},
        )
        return [package.string for package in packages]

    def install(self, packagename: str) -> bool:
        return False


pypi = PyPIWeb()
info = pypi.search('pip')

i = 0
while i < len(info):
    print(info[i], '\t', info[i + 1], '\t', info[i + 2])
    i = i + 3
