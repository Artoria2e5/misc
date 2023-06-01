import colorio
import numpy
import scipy
from scipy.optimize import minimize, NonlinearConstraint
import functools
from nptyping import Float, NDArray
from typing import Any, Union
from PIL import Image
import numpy.linalg

Color3 = Union[NDArray[(3, Any), Float], NDArray[(3,), Float]]


def rotate(rads: float, color: Color3) -> Color3:
    """Rotate a Jab/Lab-style color by a certain amount."""
    (a, b) = color[1:]
    (c, h) = (numpy.hypot(b, a), numpy.arctan2(b, a) + rads)
    return numpy.array(color[0], c * numpy.cos(h), c * numpy.sin(h))


def redmean(a: Color3, b: Color3):
    """Squared redmean RGB distance (mainly srgb with gamma)."""
    redbar = 0.5 * (a[0] + b[0])
    diff = a - b
    return (2 + redbar) * diff[0]**2 + 4 * diff[1]**2 + (2 - redbar) * diff[2]**2


def clip(a: Color3) -> Color3:
    """Clip RGB to range."""
    return numpy.clip(a, 0, 1)


def rgb_closest_redmean(a: Color3) -> Color3:
    """Find the closest point using redmean."""
    initial = clip(a)
    result = minimize(functools.partial(redmean, a), initial,
                      bounds=((0, 1), (0, 1), (0, 1)))
    if result.success:
        return result.x
    else:
        raise result


def rgb_edge_distance(colorspace: colorio.ColorSpace, a: Color3):
    """How far we are from the rgb cube. Useful as a constraint."""
    srgb = colorio.SrgbLinear.from_xyz100(colorspace.to_xyz100(colorspace))
    return numpy.linalg.norm(srgb - clip(srgb))


def edge_constraint(colorspace: colorio.ColorSpace, klass=False):
    func = functools.partial(rgb_edge_distance, colorspace)
    if klass:
        return NonlinearConstraint(func, float('-inf'), 0)
    else:
        return {
            'type': 'eq',
            'fun': func
        }


def rgb_closest_delta(colorspace: colorio.ColorSpace, a: Color3):
    initial_s = clip(colorio.SrgbLinear.from_xyz100(colorspace.to_xyz100(a)))
    initial = colorspace.from_xyz100(colorio.SrgbLinear.to_xyz100(initial_s))
    result = minimize(functools.partial(colorio.delta, a), initial,
                      bounds=edge_constraint(colorspace))
    if result.success:
        return result.x
    else:
        raise result


def process(im: Image):
    pass
