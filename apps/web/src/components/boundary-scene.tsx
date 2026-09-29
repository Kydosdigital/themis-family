"use client";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { RoundedBox, Line } from "@react-three/drei";
import { useEffect, useMemo, useRef } from "react";
import * as THREE from "three";
const tiles = [
  {
    start: [-1.8, 0.8],
    end: [-1.1, 0.75],
    colour: "#bcd0fb",
    controlled: true,
  },
  { start: [1.5, 1.2], end: [0.9, 0.75], colour: "#ffb79e", controlled: true },
  {
    start: [-0.7, -1.1],
    end: [-0.85, -1.9],
    colour: "#34d399",
    controlled: false,
  },
  {
    start: [1.9, -0.7],
    end: [1.3, -1.9],
    colour: "#7dd3fc",
    controlled: false,
  },
];
function Tile({
  index,
  progress,
  active,
}: {
  index: number;
  progress: number;
  active: boolean;
}) {
  const mesh = useRef<THREE.Mesh>(null);
  const spec = tiles[index];
  useFrame((_, dt) => {
    if (!active || !mesh.current) return;
    const p = mesh.current.position;
    p.x = THREE.MathUtils.damp(
      p.x,
      THREE.MathUtils.lerp(spec.start[0], spec.end[0], progress),
      5,
      dt,
    );
    p.y = THREE.MathUtils.damp(
      p.y,
      THREE.MathUtils.lerp(spec.start[1], spec.end[1], progress),
      5,
      dt,
    );
    mesh.current.rotation.z = THREE.MathUtils.damp(
      mesh.current.rotation.z,
      (1 - progress) * (index % 2 ? 0.25 : -0.2),
      5,
      dt,
    );
    (mesh.current.material as THREE.MeshStandardMaterial).opacity =
      spec.controlled ? 1 - progress * 0.5 : 1;
  });
  return (
    <RoundedBox
      ref={mesh}
      args={[0.8, 0.8, 0.22]}
      radius={0.13}
      smoothness={3}
      position={[spec.start[0], spec.start[1], -0.3]}
    >
      <meshStandardMaterial color={spec.colour} roughness={0.4} transparent />
    </RoundedBox>
  );
}
function Objects({ progress, active }: { progress: number; active: boolean }) {
  const group = useRef<THREE.Group>(null);
  const boundary = useRef<THREE.Group>(null);
  const time = useRef(0);
  const { invalidate, gl } = useThree();
  useEffect(() => {
    time.current = 0;
    if (active) invalidate();
  }, [progress, active, invalidate]);
  useFrame((_, dt) => {
    if (!active || !group.current || !boundary.current) return;
    time.current += dt;
    group.current.rotation.z = THREE.MathUtils.damp(
      group.current.rotation.z,
      -0.2 + progress * 0.2,
      5,
      dt,
    );
    boundary.current.scale.y = THREE.MathUtils.damp(
      boundary.current.scale.y,
      1 - progress * 0.5,
      5,
      dt,
    );
    boundary.current.position.y = THREE.MathUtils.damp(
      boundary.current.position.y,
      progress * 0.6,
      5,
      dt,
    );
    gl.domElement.setAttribute(
      "data-frames",
      String(Number(gl.domElement.getAttribute("data-frames") || 0) + 1),
    );
    if (time.current < 1.5) invalidate();
  });
  const points = useMemo(
    () =>
      Array.from({ length: 97 }, (_, i) => {
        const t = (i / 96) * Math.PI * 2;
        return new THREE.Vector3(Math.cos(t) * 2.3, Math.sin(t) * 1.5, 0);
      }),
    [],
  );
  return (
    <group ref={group} rotation={[0.15, 0, -0.2]}>
      <group ref={boundary}>
        <Line
          points={points}
          color="#2563eb"
          lineWidth={1.5}
          transparent
          opacity={0.55}
        />
        <Line
          points={points.map((p) => p.clone().multiplyScalar(1.1))}
          color="#7dd3fc"
          lineWidth={1}
          transparent
          opacity={0.4}
        />
      </group>
      {tiles.map((_, i) => (
        <Tile key={i} index={i} progress={progress} active={active} />
      ))}
    </group>
  );
}
export default function BoundaryScene({
  progress,
  active,
  onReady,
  onFail,
}: {
  progress: number;
  active: boolean;
  onReady: () => void;
  onFail: () => void;
}) {
  return (
    <div className="scene-canvas" aria-hidden="true">
      <Canvas
        camera={{ position: [0, 0, 7], fov: 43 }}
        dpr={[1, 1.5]}
        frameloop="demand"
        gl={{ antialias: true, alpha: true, powerPreference: "low-power" }}
        onCreated={({ gl }) => {
          onReady();
          gl.domElement.addEventListener("webglcontextlost", onFail, {
            once: true,
          });
        }}
        fallback={
          <span>
            Games follow the agreement. School access remains available.
          </span>
        }
      >
        <ambientLight intensity={2} />
        <directionalLight position={[3, 4, 5]} intensity={2} />
        <Objects progress={progress} active={active} />
      </Canvas>
    </div>
  );
}
