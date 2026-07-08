# Add observations to an online session

Pushes one observation or a collection of observations into the session
queue. This is the main entry point for push-style integrations.

## Usage

``` r
ingest(obj, observation)
```

## Arguments

- obj:

  Online session.

- observation:

  One observation, a list of observations, or a data frame. Each
  individual observation is normalized to the online observation
  contract used by
  [`next_observation()`](https://cefet-rj-dal.github.io/harbinger/reference/next_observation.md).

## Value

Updated `har_online_session`.
