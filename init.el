;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; https://nantonaku-shiawase.hatenablog.com/entry/2020/11/13/152436
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; send ctrl+space on windows terminal
;; https://github.com/microsoft/terminal/issues/2865#issuecomment-929522127
(global-set-key "\e[9~" 'set-mark-command)

(setq make-backup-files nil)
(setq auto-save-default nil)

(define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))

;; based on https://emacs-jp.github.io/tips/emacs-in-2020
;; more info
;; https://github.com/conao3/leaf.el
;; https://zenn.dev/zenwerk/scraps/b1280f66c8d11a
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; setting start
(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

(leaf cc-mode
  :doc "major mode for editing C and similar languages"
  :tag "builtin"
  :defvar (c-basic-offset)
  :bind (c-mode-base-map
         ("C-c c" . compile))
  :mode-hook
  (c-mode-hook . ((c-set-style "bsd")
                  (setq c-basic-offset 4)))
  (c++-mode-hook . ((c-set-style "bsd")
                    (setq c-basic-offset 4))))

(leaf paren
  :doc "highlight matching paren"
  :tag "builtin"
  :custom ((show-paren-delay . 0.1))
  :global-minor-mode show-paren-mode)

(leaf ivy
  :doc "Incremental Vertical completYon"
  :req "emacs-24.5"
  :tag "matching" "emacs>=24.5"
  :url "https://github.com/abo-abo/swiper"
  :emacs>= 24.5
  :ensure t
  :blackout t
  :leaf-defer nil
  :custom ((ivy-initial-inputs-alist . nil)
           (ivy-use-selectable-prompt . t))
  :global-minor-mode t
  :config
  (leaf swiper
    :doc "Isearch with an overview. Oh, man!"
    :req "emacs-24.5" "ivy-0.13.0"
    :tag "matching" "emacs>=24.5"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :bind (("C-s" . swiper)))

  (leaf counsel
    :doc "Various completion functions using Ivy"
    :req "emacs-24.5" "swiper-0.13.0"
    :tag "tools" "matching" "convenience" "emacs>=24.5"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :blackout t
    :bind (("C-S-s" . counsel-imenu)
           ("C-x C-r" . counsel-recentf))
    :custom `((counsel-yank-pop-separator . "\n----------\n")
              (counsel-find-file-ignore-regexp . ,(rx-to-string '(or "./" "../") 'no-group)))
    :global-minor-mode t))

(leaf prescient
  :doc "Better sorting and filtering"
  :req "emacs-25.1"
  :tag "extensions" "emacs>=25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :custom ((prescient-aggressive-file-save . t))
  :global-minor-mode prescient-persist-mode)
  
(leaf ivy-prescient
  :doc "prescient.el + Ivy"
  :req "emacs-25.1" "prescient-4.0" "ivy-0.11.0"
  :tag "extensions" "emacs>=25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :after prescient ivy
  :custom ((ivy-prescient-retain-classic-highlighting . t))
  :global-minor-mode t)

(leaf flycheck
  :doc "On-the-fly syntax checking"
  :req "dash-2.12.1" "pkg-info-0.4" "let-alist-1.0.4" "seq-1.11" "emacs-24.3"
  :tag "minor-mode" "tools" "languages" "convenience" "emacs>=24.3"
  :url "http://www.flycheck.org"
  :emacs>= 24.3
  :ensure t
  :bind (("M-n" . flycheck-next-error)
         ("M-p" . flycheck-previous-error))
  :global-minor-mode global-flycheck-mode)

(leaf company
  :doc "Modular text completion framework"
  :req "emacs-24.3"
  :tag "matching" "convenience" "abbrev" "emacs>=24.3"
  :url "http://company-mode.github.io/"
  :emacs>= 24.3
  :ensure t
  :blackout t
  :leaf-defer nil
  :bind ((company-active-map
          ("M-n" . nil)
          ("M-p" . nil)
          ("C-s" . company-filter-candidates)
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("<tab>" . company-complete-selection))
         (company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)))
  :custom ((company-idle-delay . 0)
           (company-minimum-prefix-length . 1)
           (company-transformers . '(company-sort-by-occurrence)))
  :global-minor-mode global-company-mode)

(leaf company-c-headers
  :doc "Company mode backend for C/C++ header files"
  :req "emacs-24.1" "company-0.8"
  :tag "company" "development" "emacs>=24.1"
  :added "2020-03-25"
  :emacs>= 24.1
  :ensure t
  :after company
  :defvar company-backends
  :config
  (add-to-list 'company-backends 'company-c-headers))

(leaf string-inflection
  :doc "change string format (camel/snake)"
  :ensure t
  :bind (
;         ("C-c i". string-inflection-cycle)
         ("C-c c" . string-inflection-lower-camelcase)
         ("C-c C" . string-inflection-camelcase)
         ("C-c s" . string-inflection-underscore)
         ("C-c S" . string-inflection-upcase)))

(leaf ag
  :ensure t)

(leaf magit
  :ensure t
  :bind (("C-x g". magit-status)))

(leaf helm-gtags
  :ensure t
  :bind (
         ("C-c i" . helm-imenu)
         ("C-x C-r" . helm-recentf)
         ("C-c g" . helm-gtags-find-files)
         ("M-t" . helm-gtags-find-tag)
         ("M-r" . helm-gtags-find-rtag)
         ("M-s" . helm-gtags-find-symbol)
         ("M-L" . helm-gtags-select)
         ("M-T" . helm-gtags-pop-stack))
  :global-minor-mode helm-gtags-mode)

(leaf php-mode
  :ensure t
  :url "https://github.com/emacs-php/php-mode"
  :custom ((php-enable-psr2-coding-style)))

(leaf phpunit
  :ensure t)

;; fixme mode-map
;; define-keyだとうまく動かない。eldoc-setupすると動くけど補完ミスる。
;; bindはグローバルなら動くがそれは嫌、けどmode-mapだけだとbindされない。
(leaf ac-php
  :url "https://github.com/xcwen/ac-php"
  :mode-hook
  (php-mode-hook . (;(auto-complete-mode t)
                    (setq ac-sources '(ac-source-php ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
                    (define-key php-mode-map (kbd "C-]") 'ac-php-find-symbol-at-point)
                    (define-key php-mode-map (kbd "C-t") 'ac-php-location-stack-back)
                    (yas-global-mode 1)))
  :bind (:php-mode-map ("C-]" . ac-php-find-symbol-at-point)
                       ("C-t" . ac-php-location-stack-back))
  :ensure t)

(leaf web-mode
  :url "https://web-mode.org/"
  :mode "\\.p?html?\\'" "\\.twig?\\'" "\\.css?\\'" "\\.tsx?\\'" "\\.js?\\'"
  :mode-hook
  (web-mode-hook . (
                    (setq indent-tabs-mode nil)
;                    (setq tab-width 2)
                    (setq web-mode-markup-indent-offset 2)
                    (setq web-mode-css-indent-offset 2)
                    (setq web-mode-code-indent-offset 2)
                    (lsp)
                    ))
  :setq
  (web-mode-enable-current-element-highlight . t)
  (web-mode-enable-auto-pairing . t)
  (web-mode-enable-auto-closing . t)
  :ensure t)

(leaf yaml-mode
  ensure: t)

(leaf lsp-mode
  :mode-hook
  (c-mode-hook . ((lsp)))
  (php-mode-hook . ((lsp)))
  :ensure t)

(leaf lsp-ui
  ensure: t)

;; setting end

(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
