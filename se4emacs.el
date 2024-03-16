;;; An attempt to read SE4 files with emacs
;;;; First attempt, use org-mode.

(defun convert-se4-to-org-mode ()
  (interactive)
  ;; Convert chars
  (save-excursion
    (mapc
     (function
      (lambda (pair)
	(let ((from (car pair))
	      (to (cdr pair)))
	  (goto-char (point-min))
	  (while (search-forward from nil t)
	    (replace-match to)))))
     '(("\204" . "ä")
       ("\206" . "å")
       ("\217" . "Å")
       ("\224" . "ö")
       ("\231" . "Ö")))
    (set-buffer-file-coding-system 'utf-8-unix))

  ;; Convert every item to level 2 headers.
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^#" nil t)
      (replace-match "*** ")))
  ;; Insert level 1 headers.
  (save-excursion
    (goto-char (point-min))
    (insert "Converted to org-mode.\n")
    (insert "Tips:\n")
    (insert "  Use M-x occur RET KONTO 1234 RET to get an overview of\n")
    (insert "  all transaction in an account.\n")
    (insert "* METADATA\n")
    (insert "** META\n")

    (goto-char (point-min))
    (if (re-search-forward "^\\*\\*\\* OBJEKT " nil t)
	(progn
	  (move-beginning-of-line nil)
	  (insert "** OBJEKT [%]\n")))

    (goto-char (point-min))
    (if (re-search-forward "^\\*\\*\\* KONTO " nil t)
	(progn
	  (move-beginning-of-line nil)
	  (insert "** Konton [%]\n")))

    (goto-char (point-min))
    (if (re-search-forward "^\\*\\*\\* [IU]B " nil t)
	(progn
	  (move-beginning-of-line nil)
	  (insert "** Ingående och utgående balans [%]\n")))

    (goto-char (point-min))
    (if (re-search-forward "^\\*\\*\\* RES " nil t)
	(progn
	  (move-beginning-of-line nil)
	  (insert "** RES [%]\n")))

    (goto-char (point-min))
    (if (re-search-forward "^\\*\\* \\(RES\\|Ingående\\) " nil t)
	(progn
	  (move-beginning-of-line nil)
	  (insert "* Balans och RES\n")))

    (goto-char (point-min))
    (if (re-search-forward "^\\*\\*\\* VER " nil t)
	(progn
	  (move-beginning-of-line nil)
	  (insert "* Verifikationer\n")
	  (let ((found nil))
	    (while (re-search-forward "^\\*\\*\\* \\(VER \\([0-9][0-9]*\\)\\) "
				      nil t)
	      (if (member (match-string 2) found)
		  nil
		(setq found (cons (match-string 2) found))
		(move-beginning-of-line nil)
		(insert "** " (match-string 1) " [%]\n"))))))

    ;; Setup links
    (goto-char (point-min))
    (while (re-search-forward "^\\*\\*\\* \\(KONTO [0-9][0-9][0-9][0-9]\\) "
			      nil t)
      (replace-match "<<\\1>>" t nil nil 1))

    (goto-char (point-min))
    (while (re-search-forward "#TRANS \\([0-9][0-9][0-9][0-9]\\) "
			      nil t)
      (replace-match "[[KONTO \\1][\\1]]" t nil nil 1))

    (goto-char (point-min))
    (while (re-search-forward "^\\*\\*\\* \\(IB\\|UB\\|RES\\) -?[0-9][0-9]* \\([0-9][0-9][0-9][0-9]\\) "
			      nil t)
      (replace-match "[[KONTO \\2][\\2]]" t nil nil 2))


    )

  ;; Add todos
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\*\\*\\* \\(RES 0 \\|VER \\)"
			      nil t)
      (replace-match "TODO \\1" t nil nil 1)))

  (org-mode))
