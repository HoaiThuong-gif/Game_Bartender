import struct
import unittest
from types import SimpleNamespace
import numpy as np
from nhombar_photo3d.inference import encode_native_mesh, InputError


class MeshTests(unittest.TestCase):
    def test_binary_matches_android_and_preserves_aspect_ratio(self):
        mesh = SimpleNamespace(vertices=np.array([[0, 0, 0], [2, 0, 0], [0, 1, 1]]),
                               faces=np.tile([[0, 1, 2]], (100, 1)))
        data = encode_native_mesh(mesh)
        self.assertEqual(struct.unpack('>II', data[:8]), (0x53434e31, 900))
        self.assertEqual(len(data), 7208)
        coordinates = np.frombuffer(data, dtype='>f4', count=900, offset=8).reshape(-1, 3)
        size = np.ptp(coordinates, axis=0)
        np.testing.assert_allclose(size, [.3, .15, .15], atol=1e-6)
        self.assertAlmostEqual(float(coordinates[:, 1].min()), 0)

    def test_invalid_mesh_cannot_be_returned(self):
        mesh = SimpleNamespace(vertices=np.zeros((3, 3)), faces=np.tile([[0, 1, 2]], (100, 1)))
        with self.assertRaises(InputError):
            encode_native_mesh(mesh)
        mesh.vertices[0, 0] = float('nan')
        with self.assertRaises(InputError):
            encode_native_mesh(mesh)


if __name__ == '__main__':
    unittest.main()
