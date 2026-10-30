(setq inhibit-startup-screen t)
(setq custom-file (locate-user-emacs-file "custom.el"))

; Minimalize ui
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

; UI improvements
(set-fringe-mode 10) 
(column-number-mode)
(global-display-line-numbers-mode t)
(set-face-attribute 'default nil :font "Iosevka Nerd Font" :height 135) 

; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

; Packages
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)

; Some icons
(use-package all-the-icons)

; Keybindings
(use-package general
  :config
  (general-evil-setup)
  (general-create-definer lux/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

(lux/leader-keys
  "h" '(:ignore t :which-key "Help")
  "hf" '(counsel-describe-function :which-key "Functions")
  "hv" '(counsel-describe-variable :which-key "Variable")
  "hs" '(counsel-describe-symbol :which-key "Symbol")
  "b" '(:ignore t :which-key "Buffers")
  "bb" '(counsel-buffer-or-recentf :which-key "Find buffers")
  "f" '(:ignore t :which-key "File")
  "fd" '(dired :which-key "Dired")
  "ff" '(counsel-find-file :which-key "Find file"))


; Vim my good friend
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-commentary
  :init (evil-commentary-mode 1))

; Modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1))

; Themes
(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))

; Autocompletion
(use-package ivy
  :diminish
  :bind (:map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done))
  :config (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

; Better help
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

; Projects
(use-package projectile
  :diminish projectile-mode
  :custom ((projectile-completion-system 'ivy))
  :init
  (when (file-directory-p "/mnt/6f7e372e-8cd1-4f27-980d-5342a70722c5/dev")
    (setq projectile-project-search-path '("/mnt/6f7e372e-8cd1-4f27-980d-5342a70722c5/dev")))
  (setq projectile-switch-project-action #'projectile-dired)
  :config
  (lux/leader-keys
    "p" '(:ignore t :which-key "Projects")
    "pr" '(projectile-run-project :which-key "Run")
    "pd" '(projectile-doctor :which-key "Doctor")
    "pp" '(projectile-switch-project :which-key "Find"))
  (projectile-mode))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

; Git
(use-package magit
  :config
  (lux/leader-keys
    "g" '(:ignore t :which-key "Magit")
    "gg" '(magit :which-key "Open Magit")))

;; LSP
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((c-mode . lsp-deferred)
	 (c++-mode . lsp-deferred))
  :config
  (lsp-enable-which-key-integration t)
  (lux/leader-keys
    "l" '(:keymap lsp-command-map :which-key "LSP"))
  (setq lsp-clients-clangd-args
	'("--background-index"
	  "--clang-tidy"
	  "--completion-style=detailed"
	  "--header-insertion=never")))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode))

;; LSP Completion
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind
  (:map company-active-map ("<tab>" . company-complete-selection))
  (:map lsp-mode-map ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.2))

;; LSP Diagnostics
(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode)
  (lux/leader-keys
    "lq" '(counsel-flycheck :which-key "Diagnostics")))

;; LSP Odin
(defun +odin-common-config (mode)
  (set-formatter 'odinfmt '("odinfmt" "-stdin") :modes (list mode))
  (when (modulep +lsp)
    (add-hook (intern (format "%s-local-vars-hook" mode)) #'lsp 'append))
  (map! :map ,(intern (format "%s-map" mode))
        :localleader
        "b" #'+odin/build
        "t" #'+odin/test))


(use-package odin-mode
  :ensure nil
  :mode ("\\.odin\\'" . odin-mode)
  :vc (:url "https://github.com/mattt-b/odin-mode"
       :rev :newest))

;; Terminal
(use-package term
  :config
  (setq explicit-shell-file-name "usr/bin/fish")
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :init
  (setq vterm-shell "fish")
  :config
  (setq vterm-max-scrollback 10000))
