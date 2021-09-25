# Score-based Generative Modeling in Latent Space
> Arash Vahdat, Karsten Kreis, Jan Kautz

## Summary
This paper proposes training score-based generative models (SGMs) in a latent
space (resulting in LSGM) in the interest of training more efficient and
expressive SGMs. This also allows the generation of discrete data, by allowing
the encoder-decoder of the VAE to handle conversion from discrete space to some
latent space. Rather than using a two-stage training approach (training a VAE
first, then training a SGM on the resulting latents) they train the LSGM
end-to-end. Overall, this results in a new SOTA on certain datasets whilst also
improving on sampling speed by orders of magnitude.

![Overview of the
architecture](figures/score-based-in-latent-space/architecture.png)

## Important Points
- The LSGM consists of the VAE encoder, VAE decoder and SGM prior model. Like
  with other SDE based SGM models, the encoder output $z_0$ is diffused to $z_1$
  along $t \in [0,1]$ to the standard normal distribution at $z_1$.

- The objective is split into three parts (Eq 5/6). The reconstruction and
  encoder entropy terms are easy to compute (assuming the reparameterization
  trick in the VAE encoder is available). The tricky part is the third term, the
  cross-entropy involving the SGM prior

- There is a detailed argument on how this CE term is computed. They formulate
  the prior as a geometric mixture of the normal prior and the trainable SGM
  prior, mixed using some learnable scalar $\alpha$. They first pretrain the VAE
  networks (using $\alpha = 0$) to bring the latents as close as possible to the
  standard normal prior.

- Using this mixture, the score function can be parameterized in terms of a
  mixture between the latent $z_t$ and the output of the SGM prior
  $\epsilon'_\theta(z_t, t)$ where $\theta$ are the parameters of the score
  function. The mixture is parameterized by the learnable (now vector) $\alpha$
  and applied element-wise. Eq(7) shows the final CE term.

- They discuss many different weighting mechanisms. Crucially, if weighting is
  dropped for the SGM prior, the samples improve (at small cost to likelihood).
  However, this can only be dropped for the prior (not the encoder) in order to
  bring the encoder toward the true posterior. This dropping of weightings leads
  to three different training algorithms for different situations. These are
  detailed in Appendix G.6.

- I feel the sampling speed gains are even more impressive than the actual
  improved sampling quality itself. 44 minutes (3.9 with ODE) down to 2.74
  seconds. They identify three reasons for faster sampling. Reduced spatial dim
  versus pixel-wise, mixing coefficients all $<0.02$ near end of training (so
  dominated by linear term, making ODE numerically faster to solve) and some
  artifact correction in VAE decoder. In prior work, artifacts would simply
  appear in pixel space.

- Just looking at the maths, the training process is not too clear. However,
  Appendix G.6 makes all training algorithms quite explicit. Apparently, method
  (3) consumes more memory than (2), but is often faster. I believe (1)
  corresponds to not dropping the weight for the SGM prior, so use this when
  wanting to preserve likelihood.

## Notes
- I independently had a very similar idea to try this for my masters'
  dissertation, but it seems I was beaten before I could start! Although, my
  approach would not be trained end-to-end. Such an approach is pretty inspired
  IMO and is important according to the ablation study.

- The sampling speed improvement is a huge plus, but is still not fast enough to
  be interactive. They could apply some methods in "Gotta go fast" and perhaps
  improve things further. They say "perhaps one of the first deep models that
  excel at both sample quality and distribution coverage"

- Another huge plus is the modelling of non-continuous data. Think, text,
  discrete latents, and so on. I'd also be curious to expand it beyond images to
  audio waveforms and such. They also express interest in this in the
  conclusion.

- I wonder if a discrete VAE of some sorts would improve performance further..
  Unsure how well that would perform and how to integrate that best.

- They use NVAE, but I am imagine this approach could also work with VAE, VD-VAE
  and similar continuous VAEs.

- I'd like to see results on FFHQ1024 (or similar) as Song's work with the SDE
  framework demonstrated results on that dataset. Perhaps first reducing to a
  smaller latent space will help with modelling global features (some features
  in the SDE work were inconsistent)
