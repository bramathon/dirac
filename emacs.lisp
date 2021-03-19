;; .emacs

;; ===================================
;; MELPA Package Support
;; ===================================
;; Enables basic packaging support
(require 'package)

;; Adds the Melpa archive to the list of available repositories
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")))

;; Initializes the package infrastructure
(package-initialize)

;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))

;; Installs packages
;;
;; myPackages contains a list of package names
(defvar myPackages
  '(better-defaults                 ;; Set up some better Emacs defaults
    lsp-mode                        ;; Language-server-protocol
    lsp-ui                          ;; LSP UI
    dockerfile-mode                 ;; Edit dockerfiles
    company                         ;; Autocompletion
    company-box                     ;; Make company pretty
    ;; company-lsp                     ;; lsp support for company
    csv-mode                        ;; CSV support
    crux                            ;; Collection of Ridiculously Useful eXtensions
    flycheck                        ;; Syntax checking
    blacken                         ;; Black formatting on save
    magit                           ;; Git integration
    which-key                       ;; Whick key
    material-theme                  ;; Themes
    nord-theme
    doom-themes
    doom-modeline
    fancy-battery
    solaire-mode
    helm                            ;; Helm
    helm-tramp                      ;; SSH support
    helm-lsp                        ;; Type completion
    projectile                      ;; Project navigation
    use-package                     ;; Use-package
    all-the-icons                   ;; Icon set
    yaml-mode                       ;; Mode for yaml files
    editorconfig                    ;; Mode for editorconfig files
    matlab-mode                     ;; Oh, yes
    )
  )

;; Scans the list in myPackages
;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
	    (package-refresh-contents)
            (package-install package)))
      myPackages)

;; Use packages
(use-package delight :ensure t)
(use-package use-package-ensure-system-package :ensure t)

;; ===================================
;; Basic Customization
;; ===================================

(setq inhibit-startup-message t)    ;; Hide the startup message
;; (global-linum-mode t)               ;; Enable line numbers globally

;; Set the font
;; (set-face-attribute 'default nil :font "Source Code Pro Medium")
;; (set-fontset-font t 'latin "Noto Sans")

;; ===================================
;; Theming
;; ===================================

(use-package doom-themes
  :config (load-theme 'doom-dark+ t))

(use-package doom-modeline
  :defer 0.1
  :config (doom-modeline-mode))

(use-package fancy-battery
  :after doom-modeline
  :hook (after-init . fancy-battery-mode))

(use-package solaire-mode
  :custom (solaire-mode-remap-fringe t)
  :config
  (solaire-mode-swap-bg)
  (solaire-global-mode +1))

(use-package all-the-icons
  :if (display-graphic-p)
  :config (unless (find-font (font-spec :name "all-the-icons"))
            (all-the-icons-install-fonts t)))

(menu-bar-mode -1)
(tool-bar-mode -1)

;; ====================================
;; Org Mode
;; ====================================

;; Org
(setq org-directory "~/Documents/notes/")
(define-key global-map (kbd "C-c l") 'org-store-link)
(define-key global-map (kbd "C-c a") 'org-agenda)


;; ====================================
;; Development Setup
;; ====================================

;; LSP

;; if you want to change prefix for lsp-mode keybindings.
(setq lsp-keymap-prefix "s-l")

(use-package lsp-mode
  :commands (lsp)
  :config
  (progn
    (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
    (lsp-register-client
     (make-lsp-client :new-connection (lsp-tramp-connection "pyls")
                      :major-modes '(python-mode)
                      :remote? t
                      :server-id 'remote-pyls)))
  :hook ((python-mode . lsp)
	 ;; if you want which-key integration
	 (lsp-mode . lsp-enable-which-key-integration))
  :custom
  (lsp-prefer-capf t)
  (lsp-prefer-flymake nil))

(use-package lsp-ui
  :commands lsp-ui-mode
  :config
  ;; (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  ;; (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  (define-key lsp-ui-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)
  (setq lsp-ui-doc-position 'top
	lsp-ui-imenu-enable t
	;; lsp-ui-use-webkit 't
	lsp-ui-sideline-enable nil
	lsp-ui-sideline-ignore-duplicate t))

;; (use-package dap-mode
;;   :after lsp-mode
;;   :config
;;   (dap-mode t)
;;   (dap-ui-mode t));; LSP

;; Autocompletion
(use-package company
  :after lsp-mode
  :defer 2
  :diminish
  :custom
  ;;(add-to-list 'company-backends 'company-jedi)
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(use-package company-lsp
  :after (company-lsp company)
  :config (add-to-list 'company-backends 'company-lsp))


;; performance tuning
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq gc-cons-threshold 100000000)
(setq lsp-completion-provider :capf)

;; Setup python

(use-package blacken
  :delight
  :hook (python-mode . blacken-mode))

(use-package python
  :delight "π "
  ;; :bind (("M-[" . python-nav-backward-block)
  ;;        ("M-]" . python-nav-forward-block))
  :preface
  (defun python-remove-unused-imports()
    "Removes unused imports and unused variables with autoflake."
    (interactive)
    (if (executable-find "autoflake")
        (progn
          (shell-command (format "autoflake --remove-all-unused-imports -i %s"
                                 (shell-quote-argument (buffer-file-name))))
          (revert-buffer t t t))
      (warn "python-mode: Cannot find autoflake executable."))))


;; set tramp to use ssh by default (faster)
(setq tramp-default-method "ssh")

;; Enable helm for buffer management, among other things

(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
(define-key global-map (kbd "C-c s") 'helm-tramp)
(helm-mode 1)

;; Enable which-key mode
(which-key-mode)

;; Enable editorconfig
(editorconfig-mode 1)

;; magit keybinding
(global-set-key (kbd "C-x g") 'magit-status)

;; Enable projectile

(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; Set backups directory

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)

;; Overwrite highlighted text
(delete-selection-mode 1)