'''
Launch codeml on all the alignments
 
Marco Galardini 2012
University of Florence
GPL v3.0
'''
from optparse import OptionParser, OptionGroup
from time import strftime
import sys
import os
import Bio.Phylo.PAML
from multiprocessing.queues import Queue
import multiprocessing
import time
import shutil
 
class CodeML(object):
def __init__(self, indir, align, tree):
self.indir = indir
self.align=align
self.tree=tree
def __call__(self):
from Bio.Phylo.PAML import codeml
import os
try:os.mkdir('paml')
except:pass
try:os.mkdir('paml/%s'%os.path.split(self.align)[-1])
except:pass
cml = codeml.Codeml(alignment = self.align, tree = self.tree,
out_file = "tmpcodeml/%s.out"%os.path.split(self.align)[-1],
working_dir='paml/%s'%os.path.split(self.align)[-1])
cml.set_options(NSsites = "1 2", seqtype = 1, model = 0, RateAncestor = 1)
cml.ctl_file = "../../tmpcodeml/%s.ctl"%os.path.split(self.align)[-1]
try:
res = cml.run()
shutil.move('paml/%s/rst'%os.path.split(self.align)[-1], "tmpcodeml/%s.rst"%os.path.split(self.align)[-1])
shutil.move('paml/%s/rst1'%os.path.split(self.align)[-1], "tmpcodeml/%s.rst1"%os.path.split(self.align)[-1])
except:
res = None
 
return (self.align,res)
 
class Consumer(multiprocessing.Process):
def __init__(self,
task_queue = multiprocessing.Queue(),
result_queue = multiprocessing.Queue()):
multiprocessing.Process.__init__(self)
self.task_queue = task_queue
self.result_queue = result_queue
 
def run(self):
while True:
next_task = self.task_queue.get()
time.sleep(0.01)
if next_task is None:
# Poison pill means we should exit
break
answer = next_task()
self.result_queue.put(answer)
return
 
class MultiProcess(object):
'''
Class MultiProcess
An object that can perform multiprocesses
'''
def __init__(self,ncpus=1):
self.ncpus = int(ncpus)
# Parallelization
self._parallel = None
self._paralleltasks = Queue()
self._parallelresults = Queue()
def initiateParallel(self):
self._parallel = [Consumer(self._paralleltasks,self._parallelresults)
for x in range(self.ncpus)]
for consumer in self._parallel:
consumer.start()
def addPoison(self):
for consumer in self._parallel:
self._paralleltasks.put(None)
 
def isTerminated(self):
for consumer in self._parallel:
if consumer.is_alive():
return False
return True
 
def killParallel(self):
for consumer in self._parallel:
consumer.terminate()
def doCodeML(self, indir, tree):
i = 0
dres = {}
redo = open('codemlfail.txt','w')
self.initiateParallel()
for f in os.listdir(indir):
if f[-4:] != '.phy':continue
align = os.path.join(indir, f)
obj = CodeML(indir, align, tree)
self._paralleltasks.put(obj)
# Poison pill to stop the workers
self.addPoison()
while True:
while not self._parallelresults.empty():
result = self._parallelresults.get()
if not result[1]:
msg(result[0],'ERR')
redo.write('%s\n'%result[0])
else:
msg('%s %d'%(result[0],i),'IMP')
i += 1
if self.isTerminated():
break
time.sleep(0.1)
# Get the last messages
while not self._parallelresults.empty():
result = self._parallelresults.get()
if not result[1]:
msg(result[0],'ERR')
redo.write('%s\n'%result[0])
else:
msg('%s %d'%(result[0],i),'IMP')
i += 1
self.killParallel()
return dres
 
class Highlighter:
def __init__(self):
self._msgTypes={'INF':'\033[0m',
'IMP':'\033[1;32m',
'DEV':'\033[1;34m',
'ERR':'\033[1;31m',
'WRN':'\033[1;33m'}
self._reset='\033[0m'
self._default='INF'
 
def ColorMsg(self,msg,msgLevel='INF'):
try:
s=self._msgTypes[msgLevel]+msg+self._reset
except:s=s=self._msgTypes[self._default]+msg+self._reset
return s
 
def msg(message, msgLevel='INF', sameline=False):
o=Highlighter()
if sameline:
sys.stderr.write('\r')
else:
sys.stderr.write(strftime("%H:%M:%S") + ' ')
sys.stderr.write(o.ColorMsg(message,msgLevel))
if not sameline:
sys.stderr.write('\n')
 
def creturn():
sys.stderr.write('\n')
 
def getOptions():
'''Retrieve the options passed from the command line'''
 
usage = "usage: python parallelPAML.py [options]"
parser = OptionParser(usage)
 
group1 = OptionGroup(parser, "Inputs")
group1.add_option('-a', '--aligndir', action="store", dest='align',
default='OUT',
help='Alignment directory')
group1.add_option('-t', '--tree', action="store", dest='tree',
default='TREE.nwk',
help='Tree file')
group1.add_option('-r', '--threads', action="store", dest='threads',
default=1,
help='Threads [Default: 1]')
parser.add_option_group(group1)
# Parse the options
return parser.parse_args()
(options, args) = getOptions()
 
dres = MultiProcess(options.threads).doCodeML(options.align,options.tree)
 
import json
json.dump(dres,open('codemlresults.out','w'))