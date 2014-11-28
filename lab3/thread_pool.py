import threading
from Queue import Queue

class WorkerThread(threading.Thread):
    def __init__(self, connections_queue):
        threading.Thread.__init__(self)
        self.daemon = True # set this before start to daemonise thread(program will halt if still in flight)
        self.connections_queue = connections_queue # queue for thread to pull from 
        self.start() # start up the thread
    
    def run(self):
        while True:
            f, args, kwargs = self.connections_queue.get()
            f(*args, **kwargs)
            self.connections_queue.task_done()

class ThreadPool(object):
    def __init__(self, thread_count):
        self.connections = Queue(thread_count)
        for _ in xrange(thread_count): 
        	WorkerThread(self.connections)

    def add_task(self, f, *args, **kwargs):
        self.connections.put((f, args, kwargs))

    def end(self):
		self.connections.join()
