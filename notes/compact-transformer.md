# Escaping the Big Data Paradigm with Compact Transformers
> Ali Hassani, Steven Walton, Nikhil Shah, Abulikemu Abuduweili, Jiachen Li, Humphrey Shi

## Summary
The authors aim to produce a Transformer architecture that is both compute and
data efficient - dispelling the "myth" that transformers are "data-hungry" and
only effective with large-scale training.

They introduce three models in order to do this: ViT-Lite (a smaller version of
ViT), Compact Vision Transformer (CVT: uses a novel pooling method called
SeqPool), and Compact Convolutional Transformer (CCT: adding convolutional
blocks to the tokenization step)

The compact transformer approach outperforms all other models within the domain
of small datasets, with a greatly reduced parameter count (approx 0.28 million).

## Important Points
- They put it in a rather humourful manner: "an image is **not always** worth 16
  x 16 words". Specifically, smaller patches are more appropriate for small
  datasets.

- By first applying Conv2d in the tokenization step, the model creates latent
  representation that will be more efficient for the transformer backbone. This
  also allows CCT to work with sizes that don't divide perfectly into patches
  (unlike ViT or CVT)

- Convolutions also maintains locally spatial information, which apparently
  gives flexibility toward removing positioning embeddings from the model. 

- SeqPool takes the (N x L x D) output of the transformer encoder and maps it to
  (N x D) which can then be linearly classified on. This is simply:

  $$ z = x_L^{'} x_L = softmax(g(x_L)^T)$$

- where $g$ is a mapping from the embedding dimension $d$ to a single value.
  This is essentially importance weighting across the sequence of latent
  representations. This learnable pooling apparently performs the best.

> I used a slightly different convention for matrix dimensions.

- The majority of the paper is focused on vision tasks, however, they also apply
  it to NLP experiments. The network instead takes as input the word GloVe
  embeddings. This outperforms vanilla transformer on some datasets with much
  less parameters.

## Notes
- I'd be interested to see if the SeqPool approach works on other model outputs,
  where data from an entire sequence needs to be pooled to make predictions.

> Specifically, would it be handy for the STOI-VQCPC experiments?

- I'd be curious to see how well the NLP experiments worked with learned
  embeddings. Or even on some larger tasks, see when traditional approaches
  overtake the compact transformer.

- The goal of democratizing transformers is pretty noble, and seems they have
  done well here. They crucially mention how small scale tasks have been unable
  to benefit from advancements in transformers due to the previous "data-hungry"
  approaches. Very cool ~
