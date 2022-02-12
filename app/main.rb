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
# see: https://www.scratchapixel.com/code.php?id=9&origin=/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle&src=0

# require 'app/geometry.rb'

def deg2rad(deg)
  deg * 3.14 / 180 # TODO: pi genauer
end

def tick args
  @width = 1280 / 4
  @height = 720 / 4

  @framebuffer = Array.new(@width * @height)

  @v0_z = 0
  @v1_z = 0
  @v2_z = 0

  @v0_x = -3
  @v0_y = -3
  @v1_x = 3
  @v1_y = -3
  @v2_x = 0
  @v2_y = 3
  draw args
end

def rotate vec_x,vec_y,vec_z, theta
  y = vec_y
  sinTheta = Math.sin(theta)
  cosTheta = Math.cos(theta)
  x = vec_x * cosTheta - vec_z * sinTheta
  z = vec_z * cosTheta + vec_x * sinTheta
  [x,y,z]
end

def normalize x, y, z
  _x = x.abs
  _y = y.abs
  _z = z.abs
  highest = _x > _y ? _x : (_y > _z ? _y : _z)
  [x / highest, y / highest, z / highest]
end

def draw args

  theta = args.state.tick_count / 20

  @v0_x,@v0_y,@v0_z = rotate(@v0_x,@v0_y,@v0_z,theta)
  @v1_x,@v1_y,@v1_z = rotate(@v1_x,@v1_y,@v1_z,theta)
  @v2_x,@v2_y,@v2_z = rotate(@v2_x,@v2_y,@v2_z,theta)

  cols = [{r: 1, b: 0, g: 0}, {r: 0, b: 1, g: 0}, {r: 0, b: 0, g: 1}]
  fov = 90
  scale = Math.tan(deg2rad(fov * 0.5))
  imageAspectRatio = @width / @height
  pix = 0
  @orig_x = 0
  @orig_y = 0
  @orig_z = 5
  t = 0
  u = 0
  v = 0
  j = 0
  while j < @height
    i = 0
    while i < @width
      x = (2 * (i + 0.5) / @width - 1) * imageAspectRatio * scale
      y = (1 - 2 * (j + 0.5) / @height) * scale
      @dir_x, @dir_y, @dir_z = normalize(x, y, -1)

      intersects,t,u,v = rayTriangleIntersect(t,u,v)
      if intersects
        red = u * cols[0].r + v * cols[1].r + (1 - u - v) * cols[2].r
        green = u * cols[0].g + v * cols[1].g + (1 - u - v) * cols[2].g
        blue = u * cols[0].b + v * cols[1].b + (1 - u - v) * cols[2].b
        @framebuffer[pix] = 0xFF000000 + ((red*255).to_i << 16) + ((green*255).to_i << 8) + (blue*255).to_i
      end

      pix += 1
      i += 1
    end
    j+= 1
  end
  args.pixel_array(:triangle).width = @width
  args.pixel_array(:triangle).height = @height
  args.pixel_array(:triangle).pixels = @framebuffer
  args.outputs.primitives << [0, 0, 1280, 720, :triangle].sprite

end

def cross_product x, y, z, vec3_x, vec3_y, vec3_z
  [y * vec3_z - z * vec3_y, z * vec3_x - x * vec3_z, x * vec3_y - y * vec3_x]
end

def dot x, y, z, vec3_x, vec3_y, vec3_z
  x * vec3_x + y * vec3_y + z * vec3_z
end

def rayTriangleIntersect(t, u, v)
  # compute plane's normal
  v0v1_x = @v1_x - @v0_x
  v0v1_y = @v1_y - @v0_y
  v0v1_z = @v1_z - @v0_z

  v0v2_x = @v2_x - @v0_x
  v0v2_y = @v2_y - @v0_y
  v0v2_z = @v2_z - @v0_z
  # no need to normalize
  n_x, n_y, n_z = cross_product(v0v1_x,v0v1_y,v0v1_z,v0v2_x,v0v2_y,v0v2_z)
  denom = dot(n_x, n_y, n_z, n_x, n_y, n_z)

  # Step 1: finding P

  # check if ray and plane are parallel ?
  ndotRayDirection = dot(n_x, n_y, n_z, @dir_x, @dir_y, @dir_z)

    if ndotRayDirection.abs < 1e-8 # almost 0
        return [false,t , u, v] # they are parallel so they don't intersect !
    end

  # compute d parameter using equation 2
  d = dot(n_x, n_y, n_z,@v0_x,@v0_y,@v0_z)
  d *= -1

  # compute t (equation 3)
  t = (dot(n_x, n_y, n_z, @orig_x, @orig_y, @orig_z) + d) / ndotRayDirection
  t *= -1

  # check if the triangle is in behind the ray
  if t < 0
    return [false, t , u, v] # the triangle is behind
  end

  # compute the intersection point using equation 1
  p_x = @orig_x + (t * @dir_x)
  p_y = @orig_y + (t * @dir_y)
  p_z = @orig_z + (t * @dir_z)

  # Step 2: inside-outside test
  # Vec3f C; // vector perpendicular to triangle's plane

  # edge 0
  edge0_x = @v1_x - @v0_x
  edge0_y = @v1_y - @v0_y
  edge0_z = @v1_z - @v0_z
  vp0_x = p_x - @v0_x
  vp0_y = p_y - @v0_y
  vp0_z = p_z - @v0_z
  c_x, c_y, c_z = cross_product(edge0_x, edge0_y, edge0_z, vp0_x, vp0_y, vp0_z)
  if dot(n_x,n_y,n_z,c_x,c_y,c_z) < 0
    return [false,t , u, v] # P is on the right side
  end

  # edge 1
  edge1_x = @v2_x - @v1_x
  edge1_y = @v2_y - @v1_y
  edge1_z = @v2_z - @v1_z
  vp1_x = p_x - @v1_x
  vp1_y = p_y - @v1_y
  vp1_z = p_z - @v1_z
  c_x, c_y, c_z = cross_product(edge1_x,edge1_y,edge1_z,vp1_x,vp1_y,vp1_z)
  u = dot(n_x,n_y,n_z,c_x,c_y,c_z)
  if u < 0
    return [false,t , u, v] # P is on the right side
  end

  # edge 2
  edge2_x = @v0_x - @v2_x
  edge2_y = @v0_y - @v2_y
  edge2_z = @v0_z - @v2_z
  vp2_x = p_x - @v2_x
  vp2_y = p_y - @v2_y
  vp2_z = p_z - @v2_z
  c_x, c_y, c_z = cross_product(edge2_x,edge2_y,edge2_z,vp2_x,vp2_y,vp2_z)
  v = dot(n_x,n_y,n_z,c_x,c_y,c_z)
  if v < 0
    return [false, t , u, v] # P is on the right side;
  end

  u /= denom
  v /= denom

  return [true, t , u, v] # this ray hits the triangle
end
