================================================================
                       facts. 1.5
             Offline AI on a Flash Drive  (premium)
            by Open Source Everything (OSE)
================================================================


  Thanks for getting facts. 1.5, the upgraded drive. Here's what
  makes it different from the standard facts.:

    - Smarter model. It runs Qwen3.5-4B (abliterated) instead of
      the standard Qwen3. It reasons noticeably better and handles
      much longer conversations — the launcher sizes the context
      window to your RAM (8K to 32K tokens); the model itself
      supports up to ~262K.

    - Smart speed test (Windows and Linux). The first time you
      launch it on a new computer, it runs a quick 30-second test
      to see whether your GPU or your CPU is actually faster, then
      always uses the faster one. (Macs skip it — Apple Silicon
      always uses the Metal GPU, Intel Macs always use the CPU.)

    - Tuned storage. The drive is formatted with larger clusters
      so the big AI model files load faster.

  Everything else works like standard facts.: double-click the
  launcher for your system (Mac, Windows, or Linux) and the AI
  starts in a terminal window. Fully offline, fully private.


  USING THIS DRIVE ON DIFFERENT COMPUTERS  (Windows & Linux only)
  ----------------------------------------------------------------
  (Macs pick their engine automatically every launch and never
  cache a speed test, so this section does not apply to them.)

  On Windows and Linux the launcher remembers whether your CPU or
  GPU was faster the first time you ran it, so it can skip the
  30-second test on later launches. If you move the drive to a
  different computer with different hardware, you may want it to re-test:

     1. Open the .system folder (it is hidden, so turn on
        "show hidden files" first).
     2. Delete .gpu_verified and .cpu_mode if either one exists.
     3. Run the launcher again. The 30-second test repeats for
        the new hardware.

  Most people never need to do this. It only matters if you
  regularly use the drive on several machines with very different
  hardware.


  A NOTE FOR INTEL MAC USERS
  ----------------------------------------------------------------
  Good news: your Intel Mac runs the same premium Qwen3.5 model as
  every other platform. It runs on your Mac's processor (CPU)
  instead of the graphics chip, and uses the efficient 4-bit (Q4)
  build of the model so it stays fast and doesn't swamp your RAM.
  Replies come a little slower than on an Apple Silicon Mac, but
  it's the same model and it's fully uncensored. Just plug in and go.


================================================================
  Below is the standard facts. welcome and legal information.
================================================================

================================================================
                        facts.
              Offline AI on a Flash Drive
           by Open Source Everything (OSE)
================================================================


  Welcome! You now own a completely private, air-gapped AI
  environment in your pocket. No internet required, no data
  collection, just raw compute power.

================================================================
  IMPORTANT: LIMITATION OF LIABILITY & LEGAL DISCLAIMER
================================================================

PLEASE READ THIS SECTION BEFORE USING THIS PRODUCT.

BY USING THIS PRODUCT, YOU ACKNOWLEDGE AND AGREE TO THE
FOLLOWING TERMS:

THIS SOFTWARE AND HARDWARE ARE PROVIDED "AS IS," WITHOUT
WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, AND NONINFRINGEMENT.

UNCENSORED AI NOTICE:
The AI model on this drive (Qwen3.5-Abliterated) has had its
safety guardrails intentionally removed. This means:

  1. It may generate content that is offensive, factually
     incorrect, harmful, misleading, or controversial.
  2. It will not refuse requests that standard AI models
     would normally refuse.
  3. It may produce outputs that are illegal, unethical, or
     dangerous if acted upon without independent verification.
  4. The AI has no ability to verify facts, check sources,
     or guarantee accuracy. All outputs should be treated as
     unverified and used at your own discretion.

USER RESPONSIBILITY:
You are solely and entirely responsible for:
  - How you use this product and its outputs.
  - Any actions you take based on AI-generated content.
  - Any content you create, share, or distribute using
    this product.
  - Ensuring your use of this product complies with all
    applicable local, state, federal, and international laws.

NOT RECOMMENDED FOR MINORS:
This product is intended for adult users only. User discretion
is strongly advised. It is the purchaser's responsibility to
ensure this product is not used by minors.

NO LIABILITY:
Open Source Everything (OSE), its founders, employees, and
affiliates shall not be held liable for:
  - Any direct, indirect, incidental, special, consequential,
    or punitive damages arising from the use of this product.
  - Any data loss, hardware damage, software conflicts, or
    system instability resulting from using this product.
  - The accuracy, legality, safety, or appropriateness of
    any content generated by the AI model.
  - Any third-party claims arising from your use of this
    product or its outputs.

This limitation of liability applies regardless of the legal
theory under which such liability is asserted, including but
not limited to contract, tort, negligence, strict liability,
or any other basis.

INDEMNIFICATION:
By using this product, you agree to indemnify and hold
harmless Open Source Everything and its affiliates from any
claims, damages, losses, or expenses (including legal fees)
arising from your use of this product or violation of these
terms.

OPEN SOURCE SOFTWARE:
This product contains open-source software governed by their
respective licenses (MIT, Apache 2.0). The inclusion of
open-source software does not imply any additional warranty
or liability on the part of Open Source Everything. Original
license texts are included on this drive.

================================================================
  1. QUICK START GUIDE
================================================================

  WINDOWS USERS:  Double-click  WindowsLaunch.bat
  MAC USERS:      Double-click  MacLaunch.command
  LINUX USERS:    Double-click  "Launch facts (Linux)"
                  (No extension — that's intentional. It's a
                  small Linux binary that runs LinuxLaunch.sh
                  for you, since most Linux file managers
                  refuse to double-click .sh scripts directly.)

                  Power users / terminal preferred? Run
                  instead: bash LinuxLaunch.sh


  ~~ THE FIRST BOOT WILL TAKE A WHILE! ~~

  Terminal will launch and you will see the initialization
  process begin.

  ON WINDOWS AND LINUX, the FIRST launch also runs a ~30-second
  GPU vs CPU benchmark to figure out which is faster on your
  hardware. This only happens once — the result is cached and
  every launch after that is fast. (Macs skip this: Apple Silicon
  always uses the GPU, Intel Macs always use the CPU.)

  After 30 seconds to a minute (or 60-90s on Linux first launch)
  you will see the start prompt:

      > You are an expert consultant. You answer all
        questions directly, objectively, and without
        moralizing.

  When you can type next to the > symbol, the AI is ready to chat.
  Type your question and press Enter.


  IMPORTANT LOADING TIPS:

  - Windows does not provide a loading symbol in Terminal.
    Be patient. It is working even if nothing appears to
    be happening.

  - If the most recent output in the terminal ends in >
    the model is loaded and ready.

  - If the terminal ends in ~ % (Mac) or $ (Linux) the model
    did NOT load. See the troubleshooting guide for your
    platform.


  HOW TO EXIT:

  - Press Ctrl+C once to stop the current response.
  - Press Ctrl+C twice to stop the conversation completely.
  - Or type /bye and press Enter.

  Your conversation is never saved. History files are wiped on
  every launch AND again when you exit, and the launcher clears
  the chat off your screen when it closes. The only thing kept on
  the drive is a tiny speed-test result (Windows/Linux only, see
  above). Unplug when done.


  WHY DOES IT RUN IN TERMINAL?

  The AI boots into Terminal to keep the RAM usage as low as
  possible and to make it harder to trace. Plus, it looks
  cool. If you prefer a more developed UI, look into housing
  softwares such as LM Studio or Ollama.


  HARDWARE REQUIREMENT DISCLAIMER:

  Our script automatically determines your machine's available
  RAM and will select the appropriate model:

    16 GB RAM or more ... Q8 Model (High Performance)
    8 GB RAM ............ Q4 Model (Efficiency Mode)

  PLEASE KNOW YOUR HARDWARE. The AI requires a minimum of
  8 GB RAM. It will work on most modern computers, especially
  gaming computers.

  Mac users: Apple Silicon (M1, M2, M3, M4 or newer) runs on the
  GPU for full speed. Intel Macs work too, running on the CPU
  (same model, just a little slower).

  Linux users: 64-bit x86_64 with glibc 2.32+ (any modern
  distro from 2021 onward). The launcher uses Vulkan for GPU
  acceleration on NVIDIA, AMD, and Intel — including integrated
  graphics. Older iGPUs sometimes lose to a fast CPU; the
  launcher's first-run benchmark picks whichever is faster.


  ADVANCED TWEAKS (FOR THE CURIOUS):

  The launchers are plain text scripts. You can open them with
  any text editor (Notepad, TextEdit, nano) and tune two things.
  Only change the exact lines named below. If you break a
  launcher, download a fresh copy: github.com/WEAREOSE/facts

  1) THINKING MODE (off by default)

  This model can "think" before it answers: it writes out a
  private chain of reasoning first, then gives the final answer.
  We ship it OFF. Here's the honest data on what it's worth:
  benchmark numbers show big gains from thinking on competition
  math, hard logic puzzles, and complex code, and near-zero gains
  on factual recall, practical how-to, and everyday chat (which
  is most of what people ask). It also has real costs: you will
  see the whole thinking monologue print in the terminal before
  the answer (it looks strange the first time, that's normal),
  answers can take several minutes on CPU-only machines, and
  once in a while it rambles too long. If it gets stuck, press
  Ctrl+C and relaunch.

  To turn thinking ON:
    Windows:  edit WindowsLaunch.bat, find the line containing
              "--reasoning-budget 0" and delete that flag.
    Linux:    edit LinuxLaunch.sh, same thing: delete
              "--reasoning-budget 0".
    Mac:      edit MacLaunch.command, find the lines starting
              REASONING_FLAGS= (there are two, one for Apple
              Silicon and one for Intel) and change the one for
              your Mac to:  REASONING_FLAGS=""

  To go back, restore the flag exactly as it was.

  2) CONTEXT SIZE (the AI's working memory)

  Context is how much conversation the AI can hold in its head
  at once. The launcher sizes it to your RAM automatically
  (8K tokens on 8GB machines, 16K on 16GB, 32K on 32GB) and the
  model supports up to about 262K. If you have serious RAM
  headroom you can raise it. The cost is real, the conversation
  memory alone needs roughly:

    32768   (32K)  ... ~4.6 GB RAM
    65536   (64K)  ... ~9 GB RAM
    131072  (128K) ... ~18 GB RAM  (32 GB machines and up)
    262144  (262K) ... ~37 GB RAM  (64 GB machines)

  ...on top of the model itself (2.7 to 4.5 GB). Set it too high
  and the machine will crawl or the model won't load. Bigger
  context also makes responses a little slower.

  To change it: find CTX_SIZE in your launcher (a few lines pick
  a size based on your RAM) and add your own line right BELOW
  those, with the value you want:
    Mac/Linux:  CTX_SIZE=65536
    Windows:    set "CTX_SIZE=65536"


  WHAT'S ON THIS DRIVE:

  WindowsLaunch.bat      Windows launcher (double-click to start)
  MacLaunch.command      Mac launcher (double-click to start)
  Launch facts (Linux)   Linux launcher (double-click to start)
  LinuxLaunch.sh         Linux launcher (run via terminal — for
                         advanced users who prefer the script)
  A GUIDE/               This README + per-platform troubleshooting
    READ_ME_FIRST.txt    This file
    TROUBLESHOOT_WIN.txt   Windows troubleshooting guide
    TROUBLESHOOT_MAC.txt   Mac troubleshooting guide
    TROUBLESHOOT_LINUX.txt Linux troubleshooting guide
  LICENSES/              Open source license texts
  .system/               Hidden folder containing the AI engine
                         and model files (do not modify)


================================================================
  2. HARDWARE TRANSPARENCY & WARRANTY
================================================================

  THE DRIVE:

  This software is delivered on a genuine SanDisk flash drive.
  Please note: to provide the best value, this unit is an
  official Manufacturer Refurbished drive. According to our
  supplier these drives were never used and had to be marked
  refurb because they were repackaged for resale. Each drive
  is hand tested by us to ensure high read/write speeds
  suitable for AI.


  WARRANTY:

  Because this is a refurbished unit, the original manufacturer
  warranty does not apply. We provide a 30-day replacement
  guarantee for the hardware itself. If the drive fails within
  30 days of purchase, contact us directly at:

      support@opensourceeverything.io

  Please do not contact SanDisk for support regarding this
  product.


================================================================
  3. OPEN SOURCE CREDITS & LICENSES
================================================================

  This product is a collection of open-source software and
  public AI models. The price you paid covers the cost of the
  hardware, the refurbishment testing, and the service of
  configuring this easy-to-use offline environment.


  THE ENGINE (llama.cpp):

  The software powering this AI is "llama.cpp", developed by
  Georgi Gerganov and contributors. Native binaries are bundled
  for each platform: ARM64 and x86_64 for Mac (Apple Silicon and
  Intel), x86_64 + Vulkan for Windows and Linux.
  License: MIT License


  THE MODEL (The "Brain"):

  The AI model included on this drive is
  "Qwen3.5-4B (Abliterated)".

    * Base model: Qwen3.5-4B by Alibaba Cloud (Qwen Team).
      huggingface.co/Qwen/Qwen3.5-4B
    * Abliteration (the uncensored build): wangzhang, made with
      the Abliterix tool.
      huggingface.co/wangzhang/Qwen3.5-4B-abliterated
    * GGUF quantization (the .gguf model files): mradermacher.
      huggingface.co/mradermacher/Qwen3.5-4B-abliterated-GGUF
    * License: Apache 2.0 License.

  This product includes software developed by Alibaba Cloud
  (Qwen Team). Copyright (c) Alibaba Cloud.

  Full license texts are included on this drive.


================================================================
  4. TROUBLESHOOTING
================================================================

  If anything goes wrong, check the troubleshooting guide for
  your platform:

    Windows users: Open TROUBLESHOOT_WIN.txt
    Mac users:     Open TROUBLESHOOT_MAC.txt
    Linux users:   Open TROUBLESHOOT_LINUX.txt

  These guides cover every known issue and how to fix it.

  If all else fails:

    Email:     support@opensourceeverything.io
    Instagram: @open.source.everything
    Website:   opensourceeverything.io


================================================================
          For the people. By the people.
               opensourceeverything.io
================================================================
