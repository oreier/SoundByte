import colorlog
import logging

def log_setup (level=logging.INFO, color={'INFO' : 'blue'}):
    logger = logging.getLogger()
    logger.setLevel(level)
    formatter = colorlog.ColoredFormatter("%(log_color)s%(levelname)-8s%(reset)s %(message)s",log_colors=color)
    file_handler = logging.FileHandler('Python Files\\info.log')
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)