from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

from nasbench import api

import numpy as np

from deap import algorithms
from deap import base
from deap import creator
from deap import tools

from pyDOE import *

import json

import argparse

import logging


NASBENCH_TFRECORD = '/local_home/trao_ka/data/nasbench_full.tfrecord'

INPUT = 'input'
OUTPUT = 'output'
CONV1X1 = 'conv1x1-bn-relu'
CONV3X3 = 'conv3x3-bn-relu'
MAXPOOL3X3 = 'maxpool3x3'

MODEL_DIR = './models/'

MAX_VERTICES = 7
MAX_EDGES = 9

nasbench = api.NASBench(NASBENCH_TFRECORD, seed=31081984)
adj_size = int(MAX_VERTICES * (MAX_VERTICES - 1) / 2)


def fitness(
      x,
      epochs=36,
      metric='validation_accuracy',
      logger=logging):
  adj_matrix = np.zeros((MAX_VERTICES,MAX_VERTICES), dtype=np.int8)
  adj_matrix[np.triu_indices(MAX_VERTICES, k=1)] = x[:adj_size]
  ops = [INPUT] + x[adj_size:] + [OUTPUT]
  model_spec = api.ModelSpec(
      matrix=adj_matrix,
      ops=ops)
  data = {
      'train_accuracy': 0,
      'validation_accuracy': 0,
      'test_accuracy': 0}
  if nasbench.is_valid(model_spec):
    data = nasbench.query(model_spec, epochs=epochs)
    fitness = data[metric]
  logger.info(json.dumps({
        'solution': x,
        'fitness': data[metric],
        'train_accuracy': data['train_accuracy'],
        'validation_accuracy': data['validation_accuracy'],
        'test_accuracy': data['test_accuracy'],
        'epochs': epochs
    }))
  return data[metric],


def random_init():
  edge_p = MAX_EDGES / adj_size
  adj_matrix = np.random.choice([0, 1], size=adj_size, p=[(1 - edge_p), edge_p])
  if sum(adj_matrix) > MAX_EDGES:
    ix = np.argwhere(adj_matrix==1)
    ox = np.random.choice(ix.flatten(), size=(sum(adj_matrix) - MAX_EDGES), replace=False)
    adj_matrix[ox] = 0
  ops = np.random.choice([CONV1X1, CONV3X3, MAXPOOL3X3], MAX_VERTICES - 2)
  encoded = adj_matrix.tolist() + ops.tolist()
  return encoded


def generate_lhs(size=19):
  #TODO update the size accordingly with the number of centroids
  sampling = lhs(adj_size, samples=size)
  adj_matrices = np.round(sampling).astype(int)
  ops = lhs(MAX_VERTICES - 2, samples=size)
  def sel_op(x):
    if x < 1/3:
      return CONV1X1
    elif x < 2/3:
      return CONV3X3
    else:
      return MAXPOOL3X3
  lhs_design = []
  for ix in range(size):
    encoded = adj_matrices[ix].tolist() + [sel_op(x) for x in ops[ix]]
    lhs_design.append(encoded)
  return lhs_design


LHS_design = None


def lhs_init():
  global LHS_design
  encoded = None
  for i in range(2):
    try:
      encoded = next(LHS_design)
    except:
      LHS_design = iter(generate_lhs())
    else:
      break
  return encoded


def flip_mutation(
      individual,
      indpb):
  for i in range(len(individual)):
    if np.random.rand() < indpb:
      if i < adj_size:
        individual[i] = int(not individual[i])
      else:
        tmp = [CONV1X1, CONV3X3, MAXPOOL3X3]
        tmp.remove(individual[i])
        individual[i] = np.random.choice(tmp)
  return individual,


def load_centroids(centroids_file='../../analysis/centroids_N27.json'):
  centroids = list()
  with open(centroids_file, 'r') as fp:
    data_centroids = json.load(fp)
    for key in data_centroids.keys():
      tmp = np.array(data_centroids[key][0])
      adj_matrix = tmp[np.triu_indices(7, k=1)].tolist()
      ops = data_centroids[key][1]
      ops.remove(INPUT)
      ops.remove(OUTPUT)
      encoded = adj_matrix + ops
      centroids.append(encoded)
  return centroids


centroids = None


def centroids_init():
  global centroids
  encoded = None
  for i in range(2):
    try:
      encoded = next(centroids)
    except:
      centroids = iter(load_centroids())
    else:
      break
  return encoded
  

def vanilla_GA(
      pop_size=10,
      ngen=5,
      indpb=0.05,
      cxpb=0.5,
      mutpb=0.2,
      individual_init=random_init,
      epochs=36,
      metric='validation_accuracy',
      logger=logging):
  """ Vanilla GA
    pop_size    number of individuals in the population
    ngen        number of generations before termination
    indpb       probability of mutating a single position in the encoded individual
    cxpb        crossover probability
    mutpb       mutation probability
  """
  creator.create("FitnessMax", base.Fitness, weights=(1.0,))
  creator.create("Individual", list, fitness=creator.FitnessMax)
  toolbox = base.Toolbox()
  toolbox.register("nasbench_encode", individual_init)
  toolbox.register("individual", tools.initIterate, creator.Individual, toolbox.nasbench_encode)  
  toolbox.register("population", tools.initRepeat, list, toolbox.individual)
  toolbox.register("evaluate", fitness, epochs=epochs, metric=metric, logger=logger)
  toolbox.register("mate", tools.cxOnePoint)
  toolbox.register("mutate", flip_mutation, indpb=0.05)
  toolbox.register("select", tools.selTournament, tournsize=2)
  pop = toolbox.population(n=pop_size)
  hof = tools.HallOfFame(1)
  stats = tools.Statistics(lambda ind: ind.fitness.values)
  stats.register("avg", np.mean)
  stats.register("std", np.std)
  stats.register("min", np.min)
  stats.register("max", np.max)    
  pop, log = algorithms.eaSimple(pop, toolbox, cxpb=cxpb, mutpb=mutpb, ngen=ngen, 
                                 stats=stats, halloffame=hof, verbose=False)
  acc = fitness(hof.items[0], epochs=epochs, metric='test_accuracy')
  solution = {
      'solution': hof.items[0],
      'test_accuracy': acc,
      'epochs': epochs}
  return log, solution


def vanilla_MuPlusLambdaEA(
      mu=10,
      lambda_=10,
      ngen=5,
      indpb=0.1,
      mutpb=0.8,
      individual_init=random_init,
      epochs=36,
      metric='validation_accuracy',
      logger=logging):
  """ Elite (Mu + Lambda)EA
    mu          number of individuals in the population
    lambda_     number of offspring
    ngen        number of generations before termination
    indpb       probability of mutating a single position in the encoded individual
    mutpb       mutation probability
  """
  creator.create("FitnessMax", base.Fitness, weights=(1.0,))
  creator.create("Individual", list, fitness=creator.FitnessMax)
  toolbox = base.Toolbox()
  toolbox.register("nasbench_encode", individual_init)
  toolbox.register("individual", tools.initIterate, creator.Individual, toolbox.nasbench_encode)  
  toolbox.register("population", tools.initRepeat, list, toolbox.individual)
  toolbox.register("evaluate", fitness, epochs=epochs, metric=metric, logger=logger)
  toolbox.register("mutate", flip_mutation, indpb=0.1)
  toolbox.register("select", tools.selBest)
  pop = toolbox.population(n=mu)
  hof = tools.HallOfFame(1)
  stats = tools.Statistics(lambda ind: ind.fitness.values)
  stats.register("avg", np.mean)
  stats.register("std", np.std)
  stats.register("min", np.min)
  stats.register("max", np.max)
  # No crossover... 
  pop, log = algorithms.eaMuPlusLambda(pop, toolbox, mu=mu, lambda_=lambda_,
                                 cxpb=0.0, mutpb=mutpb, ngen=ngen, 
                                 stats=stats, halloffame=hof, verbose=False)
  acc = fitness(hof.items[0], epochs=epochs, metric='test_accuracy')
  solution = {
      'solution': hof.items[0],
      'test_accuracy': acc,
      'epochs': epochs}
  return log, solution


# The original benchmark evaluates 2000 solutions, and 27 (19) centroids should
# be considered. Thus, some params are fixed. TODO: check params


def run_GA(seed, epochs, individual_init, logger):
  np.random.seed(seed)
  logger.info("## Genetic Algorithm (seed=" + str(seed) + ", epochs=" +
      str(epochs) + ", init=" + str(individual_init) + ")" )
  log, sol = vanilla_GA(
      pop_size=19,
      ngen=104, # pop_size * (n_gen + 1) = 19 * (104 +1) = 1995 ~ 2000
      indpb=0.05,
      cxpb=0.5,
      mutpb=0.2,
      individual_init=individual_init,
      epochs=epochs,
      metric='validation_accuracy',
      logger=logger)
  logger.info("### Log")
  logger.info(log)
  logger.info("### Solution")
  logger.info(json.dumps(sol))
  return log, sol


def run_EA(seed, epochs, individual_init, logger):
  np.random.seed(seed)
  logger.info("## Evolutionary Algorithm (seed=" + str(seed) + ", epochs=" +
      str(epochs) + ", init=" + str(individual_init) + ")" )
  log, sol = vanilla_MuPlusLambdaEA(
      mu=19,
      lambda_=19,
      ngen=104, # mu + lambda_ * ngen = 19 + 19 * 104 = 1995 ~ 2000
      indpb=0.1,
      mutpb=0.8,
      individual_init=individual_init,
      epochs=epochs,
      metric='validation_accuracy',
      logger=logger)
  logger.info("### Log")
  logger.info(log)
  logger.info("### Solution")
  logger.info(json.dumps(sol))
  return log, sol


formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')


def setup_logger(name, log_file, level=logging.INFO):
  handler = logging.FileHandler(log_file)        
  handler.setFormatter(formatter)
  logger = logging.getLogger(name)
  logger.setLevel(level)
  logger.addHandler(handler)
  return logger




if __name__ == '__main__':    
  parser = argparse.ArgumentParser()
  parser.add_argument(
      '--seed',
      type=int,
      default=1,
      help='Random seed.')
  parser.add_argument(
      '--logfile',
      type=str,
      default='algobench.log',
      help='Logging file.')
  parser.add_argument(
      '--ga',
      dest='ga',
      action='store_true',
      help='Run simple GA')
  parser.set_defaults(ga=False)
  parser.add_argument(
      '--ea',
      dest='ea',
      action='store_true',
      help='Run (Mu + Lambda) EA')
  parser.set_defaults(ea=False)
  parser.add_argument(
      '--centroids',
      dest='centroids',
      action='store_true',
      help='Initi using centroids (only for EA and GA)')
  parser.set_defaults(centroids=False)
  parser.add_argument(
      '--lhs',
      dest='lhs',
      action='store_true',
      help='Initi using LHS (only for EA and GA)')
  parser.set_defaults(lhs=False)
  parser.add_argument(
      '--full',
      dest='full',
      action='store_true',
      help='Run GA and (Mu + Lambda) EA 100 independent times')
  parser.set_defaults(full=False)
  parser.add_argument(
      '--epochs',
      type=int,
      default=36,
      help='Number of epochs (4, 12, 36 or 108).')

  flags, unparsed = parser.parse_known_args()

  pop = sol = None

  # This is only valid for GA and EA
  if flags.centroids:
    individual_init = centroids_init
  if flags.lhs:
    individual_init = lhs_init
  else:
    individual_init = random_init

  logger = setup_logger('main_logger', flags.logfile)
  logger.info(flags)

  if flags.ga:
    run_GA(
        seed=flags.seed,
        epochs=flags.epochs,
        individual_init=individual_init,
        logger=logger)

  if flags.ea:
    run_EA(
        seed=flags.seed,
        epochs=flags.epochs,
        individual_init=individual_init,
        logger=logger)

  if flags.full:
    logger.info("Running the full set of experiments")
    logger.info("Individual logs will be generated")
    for i in range(100):
      seed = flags.seed + i
      
      ## random initialization
      logfile = "GA.rand.36e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_GA(seed=seed, epochs=36, individual_init=random_init, logger=logger)
      logfile = "GA.rand.108e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_GA(seed=seed, epochs=108, individual_init=random_init, logger=logger)
      logfile = "EA.rand.36e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_EA(seed=seed, epochs=36, individual_init=random_init, logger=logger)
      logfile = "EA.rand.108e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_EA(seed=seed, epochs=108, individual_init=random_init, logger=logger)
      
      ## centroids init
      logfile = "GA.centroids.36e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_GA(seed=seed, epochs=36, individual_init=centroids_init, logger=logger)
      logfile = "GA.centroids.108e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_GA(seed=seed, epochs=108, individual_init=centroids_init, logger=logger)
      logfile = "EA.centroids.36e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_EA(seed=seed, epochs=36, individual_init=centroids_init, logger=logger)
      logfile = "EA.centroids.108e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_EA(seed=seed, epochs=108, individual_init=centroids_init, logger=logger)
      ### LHS

      logfile = "GA.lhs.36e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_GA(seed=seed, epochs=36, individual_init=lhs_init, logger=logger)

      logfile = "GA.lhs.108e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_GA(seed=seed, epochs=108, individual_init=lhs_init, logger=logger)

      logfile = "EA.lhs.36e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_EA(seed=seed, epochs=36, individual_init=lhs_init, logger=logger)

      logfile = "EA.lhs.108e." + str(seed) + ".log"
      logger = setup_logger(logfile, logfile)
      run_EA(seed=seed, epochs=108, individual_init=lhs_init, logger=logger)
      
    
