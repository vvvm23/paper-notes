# Autoregressive Diffusion Models
> Emiel Hoogeboom, Alexey A. Gritsenko, Jasmijn Bastings, Ben Poole, Rianne van den Berg, Tim Salimans

## Summary
This paper introduces the autoregressive diffusion model (ARDM) which are
a variant on autoregressive models that can generate in any order. They
generalize both order-agonistic autoregressive models and discrete diffusion
models. They can be trained using an efficient objective, inspired by modern
diffusion model methods. They also support limited parallel sampling,
controlled by some dynamic programming budget.

## Key Points

- Standard ARM require a predefined order in which to generate data, and
  requires the same number of function calls as the dimensionality of the data.
  Naturally, this can be horribly slow.

- ARDMs learn to generate in any order. Moreover, they require fewer steps than
  absorbing diffusion models and can generate in parallel. They are also able to "upscale" variables, such as generating from MSB to LSB in pixel values.

- Given some random ordering $\sigma$ from the set of all permutations of
  integers $1, \dots D$ and some timestep $t$ , they model $\log (x_k | x_{\sigma(<t)}) = \log \mathcal{C}(x_k | \theta_k)$ where $\mathcal{C}$ is the categorical distribution over the input with class probabilities $\theta_k$. The class probabilities are predicted by $\theta = f(m \cdot x)$ where $m$ is some boolean mask such that $m = \sigma < t$.

- In the training steps, all masked items are predicted simultaneously,
  ensuring sufficient signal to optimize the model.

- The input to the function $f$  may be different depending on the modality.
  For images and audio, it is actually the concatenation of the input with the
  mask -- allowing the model to differentiate between real masked values and the value of 0. For language, the mask it not needed as we can simply create a [MASK] class. Like diffusion models, $f$ may also condition on the time step $t$.

- Algorithm 1 and 2 show a simplified version of the sampling and training
  procedures. The final paragraph of section 3 has some additional
  implementation details.

- ARDMs can be parallelized as multiple variables can be predicted at the same
  time. In essence, we can predict $\sigma(t+k)$ for some $k>0$ whilst only
  conditioning on $\sigma(<t)$. A dynamic programming algorithm can be used to
  find out which steps to parallelize. Typically, it will "spend" more steps on
  regions with large differences in likelihood and fewer steps in regions where
  the likelihood is approximately equal (so, parallelizing less and more
  respectively). Figure 3 in the paper has a nice visualisation of this, including the cost to likelihood of parallelism, which the DP algorithms aims to minimize.

- As OA-ARDMs learn to generate in a random order, some very detailed
  information may be generated earlier in the generative process. It may make
  sense to instead generate in stages. For example, generating from the MSB to
  LSB of the variables. They propose two parameterizations of the upscaling distributions, neither having any meaningful performance difference over the other.  

- In essence, they perform competitively with other generative models whilst
  requiring less steps that other diffusion models. 

## Notes
- I haven't encountered the notion of OA-ARM before. Interesting idea!

- Only works on discrete data. They mention that future work could modify it to
  support continuous distributions.

- Would be interested in seeing more results on images, especially as other
  discrete diffusion models tend to perform excellently at high resolutions.
  They also only report likelihood scores, rather than some other metrics like
  FID. In general, results are a little lacking which makes me somewhat
  confused how well it pairs up with other models. Still a pretty excellent
  model nonetheless, but it makes me think there may still be more results to come.
