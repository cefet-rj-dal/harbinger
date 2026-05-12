set_example_seed <- function(seed = 42L) {
  seed <- as.integer(seed)

  set.seed(seed)

  if (requireNamespace("reticulate", quietly = TRUE)) {
    reticulate::py_run_string(
      "import os
import random

import numpy as np

try:
    import torch
except Exception:
    torch = None


def seed_everything(seed=42):
    seed = int(seed)

    random.seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)

    if torch is not None:
        torch.manual_seed(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed(seed)
            torch.cuda.manual_seed_all(seed)

        if hasattr(torch.backends, 'cudnn'):
            torch.backends.cudnn.deterministic = True
            torch.backends.cudnn.benchmark = False

    return seed
"
    )

    reticulate::py$seed_everything(seed)
  }

  invisible(seed)
}
