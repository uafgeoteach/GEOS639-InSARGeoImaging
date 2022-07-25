start: 
	bash setup/build.sh 2>&1 | tee setup/log


# clean notes:
# week 2 - Originally had Figs, pdf file, and GEOS639_Lab1.ipynb
# week 6 - Originally had Figs, GEOS639-Lab3-Interpre...ipynb
# week 8 - Originally had Figs, GEOS39-Lab4-SBASInSAR...ipynb
# week 9 - Originally had Figs, pdf, GEOS639-Lab5-VolcanoSourceModel...ipynb
# week 11 - Originally had Figs, GEOS639-Lab6-FeatureTracking.ipynb

clean:
	rm -rf  temp .ipython .jupyter .condarc \
			.cache .conda .bash_history \
			.bashrc .ipynb_checkpoints \
			.config ARIA-tools-docs .bash_profile .viminfo \
			.local/bin .local/lib .local/share .local/envs/.conda_envs_dir_test \
			.local/envs/unavco

# clean junk file in each course
course-clean:
	rm -rf Week-02/.ipynb_checkpoints \
		Week-08/.ipynb_checkpoints Week-08/data_LA
		Week-09/lab_6_data Week-09/.ipynb_checkpoints \
		Week-11/.ipynb_checkpoints Week-11/pycorr_iceflow Week-11/*.tif \
		Week-11/*.nc Week-11/lab_6_data

restart: clean start