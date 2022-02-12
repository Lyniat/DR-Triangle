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

require 'app/geometry.rb'

def deg2rad(deg)
  deg * 3.14 / 180 # TODO: pi genauer
end

def tick args
  #test_matrix if args.state.tick_count == 0
  draw args
end

def rotate vec, theta
  y = vec.y
  sinTheta = Math.sin(theta)
  cosTheta = Math.cos(theta)
  x = vec.x * cosTheta - vec.z * sinTheta
  z = vec.z * cosTheta + vec.x * sinTheta
  Vec3.new(x,y,z)
end

def draw args
  v0 = Vec3.new(-1, -1, 0)
  v1 = Vec3.new( 1, -1, 0)
  v2 = Vec3.new( 0,  1, 0)

  theta = args.state.tick_count / 20

  v0 = rotate(v0,theta)
  v1 = rotate(v1,theta)
  v2 = rotate(v2,theta)

  width = 1280 / 4
  height = 720 / 4
  cols = [{r: 1, b: 0, g: 0}, {r: 0, b: 1, g: 0}, {r: 0, b: 0, g: 1}]
  # Vec3f *framebuffer = new Vec3f[width * height]
  framebuffer = Array.new(width * height)
  # Vec3f *pix = framebuffer;
  fov = 51.52
  scale = Math.tan(deg2rad(fov * 0.5))
  imageAspectRatio = width / height
  pix = 0
  orig = Vec3.new(0,0,5)
  t = 0
  u = 0
  v = 0
  (0...height).each do |j|
    (0...width).each do |i|
      x = (2 * (i + 0.5) / width - 1) * imageAspectRatio * scale
      y = (1 - 2 * (j + 0.5) / height) * scale
      dir = Vec3.new(x, y, -1)
      dir = dir.normalize

      intersects,t,u,v = rayTriangleIntersect(orig,dir,v0,v1,v2,t,u,v)
      if intersects
        red = u * cols[0].r + v * cols[1].r + (1 - u - v) * cols[2].r
        green = u * cols[0].g + v * cols[1].g + (1 - u - v) * cols[2].g
        blue = u * cols[0].b + v * cols[1].b + (1 - u - v) * cols[2].b
        framebuffer[pix] = 0xFF000000 + ((red*255).to_i << 16) + ((green*255).to_i << 8) + (blue*255).to_i
      end

      pix += 1
    end
  end
  args.pixel_array(:scanner).width = width
  args.pixel_array(:scanner).height = height
  args.pixel_array(:scanner).pixels = framebuffer
  args.outputs.primitives << [0, 0, 1280, 720, :scanner].sprite

end

def rayTriangleIntersect(orig, dir, v0, v1, v2, t, u, v)
  # compute plane's normal
  v0v1 = v1 - v0
  v0v2 = v2 - v0
  # no need to normalize
  n = v0v1.crossProduct(v0v2)
  denom = n.dot(n)

  # Step 1: finding P

  # check if ray and plane are parallel ?
  ndotRayDirection = n.dot(dir)

    if ndotRayDirection.abs < 1e-8 # almost 0
        return [false,t , u, v] # they are parallel so they don't intersect !
    end

  # compute d parameter using equation 2
  d = -n.dot(v0)

  # compute t (equation 3)
  t = -(n.dot(orig) + d) / ndotRayDirection

  # check if the triangle is in behind the ray
  if t < 0
    return [false,t , u, v] # the triangle is behind
  end

  # compute the intersection point using equation 1
  p = orig + Vec3.new(t,t,t) * dir

  # Step 2: inside-outside test
  # Vec3f C; // vector perpendicular to triangle's plane

  # edge 0
  edge0 = v1 - v0
  vp0 = p - v0
  c = edge0.crossProduct(vp0)
  if n.dot(c) < 0
    return [false,t , u, v] # P is on the right side
  end

  # edge 1
  edge1 = v2 - v1
  vp1 = p - v1
  c = edge1.crossProduct(vp1)
  u = n.dot(c)
  if u < 0
    return [false,t , u, v] # P is on the right side
  end

  # edge 2
  edge2 = v0 - v2
  vp2 = p - v2
  c = edge2.crossProduct(vp2)
  v = n.dot(c)
  if v < 0
    return [false, t , u, v] # P is on the right side;
  end

  u /= denom
  v /= denom

  return [true, t , u, v] # this ray hits the triangle
end

def rotation_position args

end
