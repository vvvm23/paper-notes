# WaveGrad 2: Iterative Refinement for Text-to-Speech Synthesis
> Nanxin Chen, Yu Zhang, Heiga Zen, Ron J. Weiss, Mohammad Norouzi, Najim Dehak,
> William Chan

## Summary
The paper proposes a non-autoregressive generative model for TTS synthesis.
Precisely, it takes as input a phoneme sequence and iteratively refines a output
waveform via score matching. This allows for a trade-off between high fidelity
samples and fast sampling speeds. It uses the diffusion model approach of
predicting the noise that was applied at each step, and moving slowly in that
direction. They generate high fidelity audio that competes with a strong
autoregressive baseline. 

## Key Points
- Like other diffusion models, there is some forward corruption process and the
  network is trained to reverse this by predicting the noise at each step.

- The model consists of three modules:
    - The encoder, takes a phoneme sequence and extracts latent representations
      from it.
    - A resampling layer that changes the resolution of the encoder to match the
      output waveform time scale, quantized into 10ms segments. The model
      conditions on the duration of each segment during training, and then
      predicts this during inference.
    - The decoder, refines the output waveform iteratively, conditioned on the
      output of the resampling layer.

- The encoder is simply an embedding layer, followed by some conv layers and a
  BiLSTM with "ZeroOut" regularization. 

> ZeroOut simple stochastically forces certain hidden units to maintain the
> previous value.

- The resampling using "Gaussian Upsampling" as in "Non-attentive Tacotron"
  section 3.1.
    - This predicts the duration and "range" of each token.
    - Range controls the variance during this Gaussian upsampling process.
    - This is better than simply predicting the duration and repeating the
      vector that many times (apparently).

- During training, we only pass a random window from the encoder output to the
  decoder as it is computationally infeasible to train on a full sample. During
  inference, the full encoder sequence is used, which generates some mismatch
  between the training and inference inputs to the decoder.

- Decoder predicts noise at each diffusion step, conditioned on the encoder
  output, on the noisy waveform from the previous step, and the noise level.
  FiLM is used to combine information from the conditioning variables. This is
  somewhat hard to explain but figure 2 illustrates it somewhat nicely.

- The results show it remains competitive against autoregressive baselines
  whilst being much faster to sample from. It also outperforms other
  non-autoregressive vocoders. 

- Memory is somewhat of a concern, the biggest bottleneck being the diffusion
  decoder as it operates at the raw waveform sampling rate. However, a larger
  random window size results in improved performance (they tried 64 vs 256, or 0.8 vs 3.2 seconds of audio)

- A larger decoder is crucial to good performance, however this part is executed
  multiple times during inference, so increasing the size has a notable impact
  on sampling speed.

## Notes
- Quite close to outperforming autoregressive baselines, should only be a matter
  of time before we can get high fidelity and fast samples.

- Wondering if sampling could be done in smaller latent space, perhaps defined
  by an NVAE/VQ-VAE. This could help with memory constraints and perhaps improve
  sampling speed further. For example, an approach similar to LSGM, or even
  discrete diffusion.

- Seems to use some additional loss terms for training the duration predictor. I
  believe further details are in the non-attentive tacotron paper, but I neglect
  to add details here -- simply treating it as a black box.
