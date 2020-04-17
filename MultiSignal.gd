extends Object

class_name MultiSignal

var connected = []
signal fired

func fire():
	emit_signal("fired")

func attach(node:Node, event:String):
	node.connect(event, self, "fire")
	connected.append({"node": node, "event": event});
	
func detach_all():
	for node_pair in connected:
		node_pair.node.disconnect(node_pair.event, self, "fire")
