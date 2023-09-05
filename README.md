# Closed-loop modeling of intrinsic cardiac nervous system contributions to respiratory sinus arrhythmia

Source code of the `cardiovascular-dbi` service on o²S²PARC for the Cardiovascular Control model developed at the Daniel Baugh Institute, see original repository [here](https://github.com/Daniel-Baugh-Institute/CardiovascularControl/tree/main/v03)

## Citing the original model
If you find this repository useful for your academic work, please consider citing the associated publication:

Gee, M. M., Lenhoff, A. M., Schwaber, J. S., Ogunnaike, B. A., & Vadigepalli, R. (2023). Closed‐loop modeling of central and intrinsic cardiac nervous system circuits underlying cardiovascular control. AIChE Journal, 69(4), e18033. https://doi.org/10.1002/aic.18033

## Information for developers of the o²S²PARC Service
This Service was built starting from the [cookiecutter-osparc-service](https://github.com/ITISFoundation/cookiecutter-osparc-service).
### Usage

```console
$ make help
$ make build
$ make publish-local 
```

**Note**: the code (.sh file) and executable in `src/cardio_control/` has been generated using [MATLAB Compiler](https://ch.mathworks.com/products/compiler.html), v2020b. This requires a valid MATLAB license. 

To compile the executable that can be run with Matlab Runtime as a standalone application:
```console
{your_path_to_matlab}/bin/mcc -mv your_matlab_script.m
```

### How to test
After building the image, a Docker container can be start with:

```
docker run -it --rm -v ${PWD}/validation/input:/input -v ${PWD}/validation/output:/output docker.io/simcore/services/comp/cardiovascularcontrol-dbi:service_version_here
```
Once a new container has started, type `run` in the console. You should see the model running and outputs appearing in `validation/output`

## Have an issue or question?
Please open an issue [in this repository](https://github.com/ITISFoundation/CardiovascularControl-DBI/issues).

---
<p align="center">
<image src="https://github.com/ITISFoundation/osparc-simcore-python-client/blob/4e8b18494f3191d55f6692a6a605818aeeb83f95/docs/_media/mwl.png" alt="Made with love at www.z43.swiss" width="20%" />
</p>
