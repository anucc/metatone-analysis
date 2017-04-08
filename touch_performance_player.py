""" Plays back touch performances by sending touches over OSC back to performers """

import OSC
import random
from threading import Timer

PLAYBACK_TOUCH_PATTERN = "/metatone/playback/touch"
PLAYBACK_GESTURE_PATTERN = "/metatone/playback/gesture"

class TouchPerformancePlayer:

	def __init__(self):
		self.client = OSC.OSCClient()
		self.performers = {}
		self.local_address = ("localhost",5000)
		self.addPerformer("local","localhost",5000)

	def addPerformer(self, name, address, port):
		"""Adds a performer's address and port to the list"""
		self.performers[name] = (address, port)

	def setSynth(self, instrument = "strings"):
	    """Sends an OSC message to set the synth instrument."""
	    self.client.sendto(OSC.OSCMessage("/inst", [instrument]),address)

	def sendTouch(self, performer, x, y, velocity):
	    """Sends an OSC message to trigger a touch sound."""
	    address = self.performers[performer]
	    self.client.sendto(OSC.OSCMessage(PLAYBACK_TOUCH_PATTERN, [performer,x, y, velocity]), address)

	def playPerformance(self, perf, performer = "local"):
		"""Schedule performance of a tiny performance dataframe."""
		for row in perf.iterrows():
			Timer(row[1]['time'],self.sendTouch,args=[performer,row[1]['x'],row[1]['y'],row[1]['velocity']]).start()

# @"/metatone/playback/touch"
# 0: device
# 1: x
# 2: y
# 3: vel
# self.delegate didReceiveTouchPlayMessageFor:message.arguments[0] X:message.arguments[1] Y:message.arguments[2] vel:message.arguments[3]];

# @"/metatone/playback/gesture"
# 0: device
# 1: gesture class
# [self.delegate didReceiveGesturePlayMessageFor:message.arguments[0] withClass:message.arguments[1]];