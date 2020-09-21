from time import sleep


def sleeper(request):
    sleep(10)
    return "Function completed"