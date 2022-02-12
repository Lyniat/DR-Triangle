# based on original code by www.scratchapixel.com
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#see: https://www.scratchapixel.com/code.php?id=9&origin=/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle&src=1

class Vec2
  attr_reader :x, :y
  def initialize x, y
    @x = x
    @y = y
  end
  def +(vec2)
    Vec2.new(@x + vec2.x, @y + vec2.y)
  end
  def -(vec2)
    Vec2.new(@x - vec2.x, @y - vec2.y)
  end
  def *(vec2)
    Vec2.new(@x * vec2.x, @y * vec2.y)
  end
  def /(vec2)
    Vec2.new(@x / vec2.x, @y / vec2.y)
  end
end

class Vec3
  attr_reader :x, :y, :z

  def initialize x, y, z
    @x = x
    @y = y
    @z = z
  end

  def +(vec3)
    Vec3.new(@x + vec3.x, @y + vec3.y, @z + vec3.z)
  end

  def -(vec3)
    Vec3.new(@x - vec3.x, @y - vec3.y, @z - vec3.z)
  end

  def *(vec3)
    Vec3.new(@x * vec3.x, @y * vec3.y, @z * vec3.z)
  end

  def /(vec3)
    Vec3.new(@x / vec3.x, @y / vec3.y, @z / vec3.z)
  end

  def dot(vec3)
    @x * vec3.x + @y * vec3.y + @z * vec3.z
  end

  def norm
    @x * @x + @y * @y + @z * @z
  end

  def length
    Math.sqrt(norm)
  end

  def crossProduct(vec3)
    Vec3.new(@y * vec3.z - @z * vec3.y, @z * vec3.x - @x * vec3.z, @x * vec3.y - @y * vec3.x)
  end

  def normalize()
    n = norm()
    x = @x
    y = @y
    z = @z
    if n > 0
      factor = 1 / Math.sqrt(n)
      x = @x * factor
      y = @y * factor
      z = @z * factor
    end
    Vec3.new(x, y, z)
  end
end

class Matrix44
  attr_reader :x
  def initialize (m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44)
    @x = []
    @x << m11
    @x << m12
    @x << m13
    @x << m14
    @x << m21
    @x << m22
    @x << m23
    @x << m24
    @x << m31
    @x << m32
    @x << m33
    @x << m34
    @x << m41
    @x << m42
    @x << m43
    @x << m44
  end

  def self.get_new
    Matrix44.new(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1)
  end

  def self.get_empty
    Matrix44.new(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
  end

  def get_copy
    return Matrix44.new(
    @x[0],@x[1],@x[2],@x[3],@x[4],@x[5],@x[6],@x[7],@x[8],@x[9],@x[10],@x[11],@x[12],@x[13],@x[14],@x[15]
    )
  end

  def *(b)
    c = [][]
    i = 0
    while i < 4
      j = 0
      while j < 4
        c[i] = @x[i] * b[j * 4] + @x[i + 4] * b[1 + j * 4] + @x[i + 2 * 4] * b[2 + j * 4] + @x[i + 3 * 4] * b[3 + j * 4]
        j += 1
      end
      i += 1
    end
    c
  end

  def transposed
    t = Matrix44.get_empty
    i = 0
    while i < 4
      j = 0
      while j < 4
        t.x[i + j * 4] = @x[j + i * 4]
        j += 1
      end
      i += 1
    end
    t
  end

  def transpose!
    @x = transposed.x
  end

  def multVecMatrix(src)
    a = src.x * @x[0 + 0 * 4] + src.y * @x[1 + 0 * 4] + src.z * @x[2 + 0 * 4] + @x[3 + 0 + 4]
    b = src.x * @x[0 + 1 * 4] + src.y * @x[1 + 1 * 4] + src.z * @x[2 + 1 * 4] + @x[3 + 1 + 4]
    c = src.x * @x[0 + 2 * 4] + src.y * @x[1 + 2 * 4] + src.z * @x[2 + 2 * 4] + @x[3 + 2 * 4]
    w = src.x * @x[0 + 3 * 4] + src.y * @x[1 + 3 * 4] + src.z * @x[2 + 3 * 4] + @x[3 + 3 + 4]
    Vec3.new(a / w, b / w, c / w)
  end

  def multDirMatrix(src)
    a = src.x * @x[0 + 0 * 4] + src.y * @x[1 + 0 * 4] + src.z * @x[2 + 0 * 4]
    b = src.x * @x[0 + 1 * 4] + src.y * @x[1 + 1 * 4] + src.z * @x[2 + 1 * 4]
    c = src.x * @x[0 + 2 * 4] + src.y * @x[1 + 2 * 4] + src.z * @x[2 + 2 * 4]
    Vec3.new(a,b,c)
  end

  # see: https://stackoverflow.com/questions/1148309/inverting-a-4x4-matrix
  def inverse
    inv = Array.new(16)
    det = 0
    i = 0

    inv[0] = @x[5]  * @x[10] * @x[15] -
      @x[5]  * @x[11] * @x[14] -
      @x[9]  * @x[6]  * @x[15] +
      @x[9]  * @x[7]  * @x[14] +
      @x[13] * @x[6]  * @x[11] -
      @x[13] * @x[7]  * @x[10]

    inv[4] = -@x[4]  * @x[10] * @x[15] +
      @x[4]  * @x[11] * @x[14] +
      @x[8]  * @x[6]  * @x[15] -
      @x[8]  * @x[7]  * @x[14] -
      @x[12] * @x[6]  * @x[11] +
      @x[12] * @x[7]  * @x[10]

    inv[8] = @x[4]  * @x[9] * @x[15] -
      @x[4]  * @x[11] * @x[13] -
      @x[8]  * @x[5] * @x[15] +
      @x[8]  * @x[7] * @x[13] +
      @x[12] * @x[5] * @x[11] -
      @x[12] * @x[7] * @x[9]

    inv[12] = -@x[4]  * @x[9] * @x[14] +
      @x[4]  * @x[10] * @x[13] +
      @x[8]  * @x[5] * @x[14] -
      @x[8]  * @x[6] * @x[13] -
      @x[12] * @x[5] * @x[10] +
      @x[12] * @x[6] * @x[9]

    inv[1] = -@x[1]  * @x[10] * @x[15] +
      @x[1]  * @x[11] * @x[14] +
      @x[9]  * @x[2] * @x[15] -
      @x[9]  * @x[3] * @x[14] -
      @x[13] * @x[2] * @x[11] +
      @x[13] * @x[3] * @x[10]

    inv[5] = @x[0]  * @x[10] * @x[15] -
      @x[0]  * @x[11] * @x[14] -
      @x[8]  * @x[2] * @x[15] +
      @x[8]  * @x[3] * @x[14] +
      @x[12] * @x[2] * @x[11] -
      @x[12] * @x[3] * @x[10]

    inv[9] = -@x[0]  * @x[9] * @x[15] +
      @x[0]  * @x[11] * @x[13] +
      @x[8]  * @x[1] * @x[15] -
      @x[8]  * @x[3] * @x[13] -
      @x[12] * @x[1] * @x[11] +
      @x[12] * @x[3] * @x[9]

    inv[13] = @x[0]  * @x[9] * @x[14] -
      @x[0]  * @x[10] * @x[13] -
      @x[8]  * @x[1] * @x[14] +
      @x[8]  * @x[2] * @x[13] +
      @x[12] * @x[1] * @x[10] -
      @x[12] * @x[2] * @x[9]

    inv[2] = @x[1]  * @x[6] * @x[15] -
      @x[1]  * @x[7] * @x[14] -
      @x[5]  * @x[2] * @x[15] +
      @x[5]  * @x[3] * @x[14] +
      @x[13] * @x[2] * @x[7] -
      @x[13] * @x[3] * @x[6]

    inv[6] = -@x[0]  * @x[6] * @x[15] +
      @x[0]  * @x[7] * @x[14] +
      @x[4]  * @x[2] * @x[15] -
      @x[4]  * @x[3] * @x[14] -
      @x[12] * @x[2] * @x[7] +
      @x[12] * @x[3] * @x[6]

    inv[10] = @x[0]  * @x[5] * @x[15] -
      @x[0]  * @x[7] * @x[13] -
      @x[4]  * @x[1] * @x[15] +
      @x[4]  * @x[3] * @x[13] +
      @x[12] * @x[1] * @x[7] -
      @x[12] * @x[3] * @x[5]

    inv[14] = -@x[0]  * @x[5] * @x[14] +
      @x[0]  * @x[6] * @x[13] +
      @x[4]  * @x[1] * @x[14] -
      @x[4]  * @x[2] * @x[13] -
      @x[12] * @x[1] * @x[6] +
      @x[12] * @x[2] * @x[5]

    inv[3] = -@x[1] * @x[6] * @x[11] +
      @x[1] * @x[7] * @x[10] +
      @x[5] * @x[2] * @x[11] -
      @x[5] * @x[3] * @x[10] -
      @x[9] * @x[2] * @x[7] +
      @x[9] * @x[3] * @x[6]

    inv[7] = @x[0] * @x[6] * @x[11] -
      @x[0] * @x[7] * @x[10] -
      @x[4] * @x[2] * @x[11] +
      @x[4] * @x[3] * @x[10] +
      @x[8] * @x[2] * @x[7] -
      @x[8] * @x[3] * @x[6]

    inv[11] = -@x[0] * @x[5] * @x[11] +
      @x[0] * @x[7] * @x[9] +
      @x[4] * @x[1] * @x[11] -
      @x[4] * @x[3] * @x[9] -
      @x[8] * @x[1] * @x[7] +
      @x[8] * @x[3] * @x[5]

    inv[15] = @x[0] * @x[5] * @x[10] -
      @x[0] * @x[6] * @x[9] -
      @x[4] * @x[1] * @x[10] +
      @x[4] * @x[2] * @x[9] +
      @x[8] * @x[1] * @x[6] -
      @x[8] * @x[2] * @x[5]

    det = @x[0] * inv[0] + @x[1] * inv[4] + @x[2] * inv[8] + @x[3] * inv[12]

    if det == 0
      return nil
    end

    det = 1.0 / det

    out = Matrix44.get_empty
    i = 0
    while i < 16
      out.x[i] = inv[i] * det
      i += 1
    end
    out
  end

  def invert!
    inv = inverse
    i = 0
    while i < 4
      j = 0
      while j < 4
        @x[[i,j]] = inv.x[[i,j]]
        j += 1
      end
      i += 1
    end
  end

  def to_s
    s = ""
    j = 0
    while j < 4
      i = 0
      while i < 4
        s << "m#{j+1}#{i+1} #{@x[i + j * 4]},  "
        i += 1
      end
      j += 1
    end
    s
  end
end

def test_matrix
  t = Matrix44.new(0.707107, 0, -0.707107, 0, -0.331295, 0.883452, -0.331295, 0, 0.624695, 0.468521, 0.624695, 0, 4.000574, 3.00043, 4.000574, 1)
  trans = Matrix44.new(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
  puts t
  #t.invert!
  puts t.inverse
  #puts t
  #puts (trans.transposed)
end
