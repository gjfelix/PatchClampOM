within PatchClamp.Examples;
model Step06_HodgkinHuxleyActionPotential
  "Experimento 02: Potencial de accion en neuronas HH en current-clamp"

  // ── Componentes del circuito ─────────────────────────────────────────
  PatchClamp.Amplifiers.CurrentClampAmplifier amplifier(
    I_hold        = 0.0,
    I_pulse       = 30.0e-12,
    t_pulse_start = 0.010,
    t_pulse_end   = 0.015,
    R_bridge      = 4.0e6)
    "Amplificador current-clamp: pulso 30 pA durante 5 ms (t=10-15 ms); umbral ~29 pA"
    annotation(Placement(transformation(extent={{-190,-40},{-110,40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = -11.0e-3)
    "Pipeta de patch: R=4 MOhm, C=3 pF, LJP=-11 mV"
    annotation(Placement(transformation(extent={{-90,-40},{-10,40}})));

  PatchClamp.Cells.HodgkinHuxleyNeuron neuron(
    C_m     = 10.0e-12,
    A       = 1000.0e-12,
    g_Na_max = 1200.0,
    g_K_max  = 360.0,
    g_L      = 3.0,
    E_Na     = 0.050,
    E_K      = -0.077,
    E_L      = -0.0544)
    "Neurona Hodgkin-Huxley: conductancias canonicas, T=6.3 C equivalente"
    annotation(Placement(transformation(extent={{10,-40},{90,40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    "Electrodo de bano: referencia a 0 V"
    annotation(Placement(transformation(extent={{110,-40},{190,40}})));

equation
  // ── Conexiones del circuito ──────────────────────────────────────────
  // Amplificador → Pipeta
  connect(amplifier.p, pipette.p_amp)
    annotation(Line(points={{-110,0},{-90,0}}, color={0,0,255}));

  // Pipeta → Neurona
  connect(pipette.p_cell, neuron.membrane_p)
    annotation(Line(points={{-10,0},{10,0}}, color={0,0,255}));

  // Neurona → Electrodo de bano
  connect(neuron.membrane_n, bath.p)
    annotation(Line(points={{90,0},{110,0}}, color={0,0,255}));

  // Bus de tierra: amplificador y electrodo de bano
  connect(amplifier.n, bath.n)
    annotation(Line(points={{-190,0},{-190,-80},{190,-80},{190,0}}, color={0,0,255}));

  // Tierra de la pipeta al bus de tierra
  connect(pipette.n, bath.n)
    annotation(Line(points={{-50,-40},{-50,-80},{190,-80},{190,0}}, color={0,0,255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step06 -- Potencial de accion Hodgkin-Huxley en current-clamp</h2>

      <h3>Objetivo de aprendizaje</h3>
      <p>
        Generar y analizar un potencial de accion (PA) en el modelo clasico
        de Hodgkin y Huxley (1952). Comprender como la inyeccion de una
        corriente umbral desencadena una respuesta todo-o-nada, y como las
        variables de compuerta m, h y n describen la cinetica de los canales
        de Na+ y K+ durante el PA.
      </p>

      <h3>Protocolo</h3>
      <pre>
  t = 0    - 10 ms:  I_command = 0 pA   (reposo)
  t = 10   - 15 ms:  I_command = 10 pA  (estimulo umbral)
  t = 15   - 50 ms:  I_command = 0 pA   (observar respuesta)
      </pre>

      <h3>Que observar</h3>
      <ul>
        <li>
          Variables a graficar: neuron.V_m (potencial de membrana en V),
          neuron.m, neuron.h, neuron.n (variables de compuerta, sin unidad),
          neuron.I_Na, neuron.I_K (corrientes ionicas en A).
        </li>
        <li>
          Potencial de reposo: V_m = -65 mV (condicion inicial fijada
          por los valores iniciales de m, h, n en estado estacionario).
        </li>
        <li>
          Umbral de disparo: aproximadamente -55 mV. Por debajo del umbral
          no se genera PA; por encima se dispara un PA completo.
        </li>
        <li>
          Secuencia del PA: depolarizacion rapida por apertura de Na+
          (m sube, h permanece alto), repolarizacion por inactivacion de Na+
          (h baja) y apertura de K+ (n sube), hiperpolarizacion transitoria
          (post-hyperpolarization) mientras K+ se cierra (n baja).
        </li>
      </ul>

      <h3>Valores de referencia</h3>
      <pre>
  V_reposo   = -65 mV
  V_umbral   = approx -55 mV
  V_pico     = approx +35 mV
  Duracion PA = approx 2-3 ms (a 6.3 C equivalente)
  I_Na pico  = ordenes de nA, supera ampliamente I_K
      </pre>

      <h3>Preguntas de reflexion</h3>
      <ol>
        <li>
          Reduce I_pulse a 5 pA. Se sigue generando el PA? Que pasa con
          8 pA? Esto ilustra el concepto de umbral todo-o-nada.
        </li>
        <li>
          Observa la variable m durante la depolarizacion: es la compuerta
          de activacion de Na+. Por que sube tan rapidamente comparada con n?
        </li>
        <li>
          Por que existe una hiperpolarizacion despues del PA?
          Cuales canales la producen y cuanto dura?
        </li>
        <li>
          Aplica un segundo pulso a t=30 ms (durante el periodo refractario).
          Se genera un segundo PA? Por que no?
        </li>
        <li>
          Aumenta I_pulse a 50 pA mantenido (quita el t_pulse_end).
          Cuantos potenciales de accion se generan? Esto se llama
          tren de disparos (firing train).
        </li>
      </ol>

      <h3>Equivalente experimental</h3>
      <p>
        Replica el experimento original de Hodgkin y Huxley en axon gigante
        de calamar (Loligo), adaptado a current-clamp whole-cell en neuronas
        corticales de mamifero. El modelo usa los parametros originales de
        Hodgkin and Huxley (1952) J. Physiol. 117:500-544.
      </p>

      <h3>Referencia</h3>
      <p>
        Hodgkin AL, Huxley AF (1952). A quantitative description of membrane
        current and its application to conduction and excitation in nerve.
        J Physiol 117:500-544.
      </p>
    </html>"),
    experiment(
      StopTime  = 0.050,
      Interval  = 1e-5,
      Tolerance = 1e-8),
    Diagram(graphics = {
      Line(
        points = {{-190,-80},{190,-80}},
        color = {0,0,255},
        thickness = 0.5),
      Text(
        extent = {{-190,-82},{-120,-96}},
        textString = "GND bus",
        textColor = {0,0,200},
        fontSize = 9),
      Text(
        extent = {{-240,60},{-110,44}},
        textString = "I-clamp",
        textColor = {0,80,160},
        fontSize = 9),
      Text(
        extent = {{-100,60},{30,44}},
        textString = "Pipeta",
        textColor = {0,100,0},
        fontSize = 9),
      Text(
        extent = {{10,60},{100,44}},
        textString = "HH Neuron",
        textColor = {0,0,180},
        fontSize = 9),
      Text(
        extent = {{110,60},{200,44}},
        textString = "Bath",
        textColor = {150,80,0},
        fontSize = 9)
    }),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 80, 160},
        fillColor = {230, 242, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 30}, {90, -10}},
        textString = "Step06",
        textColor = {0, 60, 130},
        fontSize = 22),
      Text(
        extent = {{-90, -10}, {90, -40}},
        textString = "HH Action Potential",
        textColor = {0, 80, 160},
        fontSize = 11)
    })
  );
end Step06_HodgkinHuxleyActionPotential;