"""
This module is a library for micropython.
Copyright (c) 2015, Moklyak Alexandr.

The example that repeats example for work with Timer() described in
micropython.org:
>>> from pyb import LED
>>> from timethread import TimeThread
>>> th = TimeThread(1)
>>> def func():
>>>     LED(3).toggle()
>>>     th.set_time_out(2000, func)
>>> func()
>>> th.run()

In function func() you can write much more complex code now.
This code also can contain memory allocation now.
It should also be noted that the number of methods calls set_time_out() can
be anything. Also, in each call individual time interval can be set.
The only limitation is function pointer should be unique. The method
set_time_out() is the pointer for uniqueness and if pointer is not unique
then nothing is added.
"""

from pyb import Timer

class TimeThread(object):
    """
    This class allows to make a call of several functions with a specified time
    intervals. For synchronization a hardware timer is used. The class contains
    main loop to check flags of queue.
    """
    def __init__(self, timerNum, showExceptions = False):
        self.showExceptions = showExceptions
        self.timerQueue = []
        self.timer = Timer(timerNum, freq=1000)
        self.timer.callback(self._timer_handler)

    """
    The method adds a pointer of function and delay time to the event queue.
    Time interval should be set in milliseconds.
    When the method adds to the queue it verifies uniqueness for the pointer.
    If such a pointer already added to an event queue then it is not added again.
    When the queue comes to this pointer then entry is removed from the queue.
    But the pointer function is run.
    """
    def set_time_out(self, delay, function):
        b = True
        for r in self.timerQueue:
            if r[1] == function:
                b = False
        if b:
            self.timerQueue += [[delay, function]]        

    # The handler of hardware timer
    def _timer_handler(self, timer):
        q = self.timerQueue
        for i in range(len(q)):
            if q[i][0] > 0:
                q[i][0] -= 1

    """
    The method runs an infinite loop in wich the queue is processed. 
    This method should be accessed after pre-filling queue.    
    Further work is performed within the specified (by the method
    set_time_out()) functions.
    """
    def run(self):
        q = self.timerQueue
        while True:            
            for i in range(len(q) - 1, -1, -1):
                if q[i][0] == 0:
                    f = q[i][1]
                    del(q[i])
                    if self.showExceptions:                        
                        f()
                    else:
                        try:
                            f()
                        except Exception as e:
                            print(e)
