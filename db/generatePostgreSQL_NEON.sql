CREATE TABLE IF NOT EXISTS public.users
(
    user_id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    username character varying(50) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    father_name character varying(50),
    gender character varying(6),
    email character varying(100) NOT NULL,
    password_hash character varying(200) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    superuser boolean DEFAULT false,
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT users_email_key UNIQUE (email),
    CONSTRAINT users_username_key UNIQUE (username)
);

CREATE TABLE IF NOT EXISTS public.posts (
    post_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    technology3d VARCHAR(8),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    code3d TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION
update_posts_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_posts_modtime
BEFORE UPDATE ON public.posts
FOR EACH ROW
EXECUTE FUNCTION update_posts_modified();

CREATE TABLE comments (
  comment_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  post_id INTEGER NOT NULL,
  parent_comment_id INTEGER NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

CREATE TABLE post_likes (
  user_id INTEGER NOT NULL,
  post_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

CREATE TABLE comment_likes (
  user_id INTEGER NOT NULL,
  comment_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, comment_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

CREATE TABLE private_messages (
  message_id SERIAL PRIMARY KEY,
  sender_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  receiver_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP NULL
);

CREATE TABLE deleted_messages (
  user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  message_id INTEGER NOT NULL REFERENCES private_messages(message_id) ON DELETE CASCADE,
  deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, message_id)
);


INSERT INTO public.users (username, first_name, last_name, father_name, gender, email, password_hash, superuser)
VALUES (
    'Alex',
    'Александр',
    'Красиков',
    'Иванович',
    'male',
    'code3d@mail.ru',
    'scrypt:32768:8:1$iqScUwfzIPVpPAJP$2f1164eaf1151689b6f1eb37af178162e8bc0765ea3042b67316bb2385ab7d1e3d73ad15cb4656c3d173924c5ea5931009b1a1e27b87d829c00a1112f59b7e56',
    true
);


INSERT INTO public.posts (user_id, technology3d, title, content, code3d, type_of_work)
VALUES
(
    (SELECT user_id FROM public.users WHERE username = 'Alex'),
    'x3dom',
    'Разработка X3D-сцены, её представление в формате HTML-страницы и визуализация в Web-браузере',
    '1. Цель работы1
2
3
4
5
6
7
8
9
0

Целью работы является ознакомление с принципами использования геометрических объектов для построения X3D-сцен. Ознакомление с узлами пространственных преобразований, группировки и тиражирования объектов X3D-сцены, создания гиперссылок и задания свойств материалов и текстур геометрических объектов, а также принципами создания HTML-страниц с внедренным X3D-кодом.
2. Номер варианта
Вариант №10
Простые геометрические узлы: Box, Cylinder, Text, Pyramid, Dish, Transform, Shape.
Сложные геометрические узлы: IndexedTriangleStripSet, Extrusion.
Группирование и встраивание: DEF/USE, Group, Anchor.
Текстурирование (Texture): Appearance, Material, PixelTexture.
3 Словесное описание сцены
На данной сцене изображен андроид, состоящий из цилиндров, полусфер и сфер, и дом, состоящий из бокса, пирамиды, экструзии и индексированного набора треугольных полос. Также над андроидом есть текст, который открывает википедию при нажатии.',
    '<scene render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" pickmode="idBuf" dopickpass="true" shadowobjectidmapping="">
          <!-- Text -->
          <anchor url="https://ru.wikipedia.org/wiki/Android" parameter="target=''_self''" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" description="">
            <transform translation="0 2 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
              <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                <text string="ANDROID" solid="false" ccw="true" usegeocache="true" lit="true" maxextent="0">
                      <fontstyle family="courier" size="0.6" justify="middle" style="BOLD" language="en" horizontal="true" lefttoright="true" spacing="1" toptobottom="true" quality="2"></fontstyle>
                    </text>
                    <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                      <material diffusecolor="1 0 0" ambientintensity="0.2" emissivecolor="0,0,0" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
                    </appearance>
              </shape>
            </transform>
          </anchor>

          <!-- HOUSE -->
          <transform translation="-2 0 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
            <group def="HOUSE" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0">
              <transform translation="-6 1.5 -10" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                  <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                    <pixeltexture image="1 4 4 0x114411ff 0x000f10f1 0x0000ffff 0x00ffffff" origchannelcount="0" url="" repeats="true" repeatt="true" scale="true" crossorigin="" flipy="false" channel="0">
                              <textureproperties anisotropicdegree="1" bordercolor="0,0,0,0" borderwidth="0" boundarymodes="REPEAT" boundarymodet="REPEAT" boundarymoder="REPEAT" magnificationfilter="FASTEST" minificationfilter="FASTEST" texturecompression="FASTEST" texturepriority="0" generatemipmaps="false"></textureproperties>
                          </pixeltexture>
                  </appearance>
                  <box size="7 7 7" solid="true" ccw="true" usegeocache="true" lit="true" hashelpercolors="false"></box>
                </shape>
              </transform>

              <transform translation="-6 6.5 -10" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                    <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                        <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                          <material diffusecolor="0 1 0" ambientintensity="0.2" emissivecolor="0,0,0" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
                        </appearance>
                        <pyramid height="3" xbottom="8" ybottom="8" xtop="0" ytop="0" xoff="0" yoff="0" solid="true" ccw="true" usegeocache="true" lit="true"></pyramid>
                      </shape>
                  </transform>

                  <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                  <indexedtriangleset index="0 1 2 3 4 5" solid="false" ccw="true" usegeocache="true" lit="true" colorpervertex="true" normalpervertex="true" normalupdatemode="fast">
                  <coordinate point="-3.5 7 -9, -3.5 8 -9, -2.5 9 -9,
                  -3.5 7 -9,-3.5 8 -9, -5.5 9 -9"></coordinate>
                  <colorrgba color="0 0 0 .1, 0 0 0 .7, 1 1 1 .8,
                  0 0 0 .1, 0 0 0 .7, 1 1 1 .8"></colorrgba>
                </indexedtriangleset>
                </shape>

                <transform scale=".4,1.5,.4" translation="-3.5 5.8 -9" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scaleorientation="0,0,0,0">
                      <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                          <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                            <material diffusecolor="#4D220E" ambientintensity="0.2" emissivecolor="0,0,0" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
                        </appearance>
                        <extrusion crosssection="1 -2.44921e-016 0.932472 -0.361242 0.739009
                        -0.673696 0.445738 -0.895164 0.0922675 -0.995734 -0.273664 -0.961825
                        -0.602635 -0.798017 -0.850218 -0.526432 -0.982973 -0.183749 -0.982973
                        0.18375 -0.850217 0.526433 -0.602634 0.798018 -0.273663 0.961826
                        0.0922688 0.995734 0.445739 0.895163 0.739009 0.673695 0.932472
                        0.361241 1 -2.44921e-016" scale="1 1 1 1" solid="true" ccw="true" usegeocache="true" lit="true" begincap="true" endcap="true" convex="true" creaseangle="0" orientation="0,0,0,0" spine="0,0,0,0,1,0" height="0">
                        </extrusion>
                      </shape>
                  </transform>
            </group>
          </transform>

          <!-- GROUND -->
          <transform translation="0 -2 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
            <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
              <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                <material diffusecolor="0 .1 0" emissivecolor="0 .2 0" ambientintensity="0.2" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
              </appearance>
              <box size="40 0 40" solid="true" ccw="true" usegeocache="true" lit="true" hashelpercolors="false"></box>
            </shape>
          </transform>


          <group def="ANDROID" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0">
            <transform translation="0 -.35 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
              <!-- BODY -->
              <transform translation="0 0 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                  <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                    <material diffusecolor="green" ambientintensity="0.2" emissivecolor="0,0,0" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
                  </appearance>
                  <cylinder height="1.5" radius="1" solid="true" ccw="true" usegeocache="true" lit="true" bottom="true" top="true" subdivision="32" side="true"></cylinder>
                </shape>
              </transform>

                  <transform translation="0 0.85 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                    <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                      <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                          <material diffusecolor="green" ambientintensity="0.2" emissivecolor="0,0,0" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
                        </appearance>
                        <dish radius="1" diameter="2" solid="true" ccw="true" usegeocache="true" lit="true" height="1" bottom="true" subdivision="24,24"></dish>
                    </shape>
                </transform>

                <!-- LEFT HAND -->
                <transform center="0,0.8,0" translation="1.3 0 0" rotation="1  0  0  -.7" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" scale="1,1,1" scaleorientation="0,0,0,0">
                  <group def="HAND" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0">
                    <group def="FOOT" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0">
                    <transform translation="0 0.6 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                          <shape def="top hand" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                            <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                                <material diffusecolor="green" ambientintensity="0.2" emissivecolor="0,0,0" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
                              </appearance>
                              <dish radius="0.25" diameter=".5" solid="true" ccw="true" usegeocache="true" lit="true" height="1" bottom="true" subdivision="24,24"></dish>
                        </shape>
                      </transform>
                      <transform translation="0 0.25 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                        <transform translation="0 0 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                          <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                          <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                            <material diffusecolor="green" ambientintensity="0.2" emissivecolor="0,0,0" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
                          </appearance>
                          <cylinder height=".7" radius="0.25" solid="true" ccw="true" usegeocache="true" lit="true" bottom="true" top="true" subdivision="32" side="true"></cylinder>
                        </shape>
                        </transform>
                        <transform translation="0 -0.35 0" rotation="1  0  0  3.14" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                          <shape use="top hand"></shape>
                        </transform>
                    </transform>
                  </group>
                </group>
              </transform>

              <!-- RIGHT HAND -->
              <transform center="0,0.8,0" translation="-1.3 0 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                <group use="HAND"></group>
              </transform>

              <!-- LEFT FOOT -->
              <transform center="0,0.8,0" translation=".5 -1.3 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                <group use="FOOT"></group>
              </transform>

              <!-- RIGHT FOOT -->
              <transform center="0,0.8,0" translation="-.5 -1.3 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                <group use="FOOT"></group>
              </transform>

              <!-- RIGHT antenna -->
              <transform center="0,-0.2,0" scale=".25,.5,.25" rotation="0  0  1  .7" translation="-.5 1.9 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" scaleorientation="0,0,0,0">
                <group use="FOOT"></group>
              </transform>

              <!-- LEFT antenna -->
              <transform center="0,-0.2,0" scale=".25,.5,.25" rotation="0  0  1  -.7" translation=".5 1.9 0" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" scaleorientation="0,0,0,0">
                <group use="FOOT"></group>
              </transform>

              <!-- LEFT eye -->
              <transform translation=".35 1.4 .7" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                <group def="EYE" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0">
                  <shape render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" ispickable="true" idoffset="0">
                          <appearance sorttype="auto" sortkey="0" alphaclipthreshold="0.1">
                            <material diffusecolor="white" ambientintensity="0.2" emissivecolor="0,0,0" shininess="0.2" specularcolor="0,0,0" transparency="0"></material>
                          </appearance>
                          <sphere radius=".1" solid="true" ccw="true" usegeocache="true" lit="true" subdivision="24,24"></sphere>
                      </shape>
                  </group>
              </transform>

              <!-- RIGHT eye -->
              <transform translation="-.35 1.4 .7" render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" center="0,0,0" rotation="0,0,0,0" scale="1,1,1" scaleorientation="0,0,0,0">
                <group use="EYE"></group>
              </transform>

            </transform>
          </group>
        <matrixtransform render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" matrix="1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1"><inline render="false" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" url="" load="true" description="" namespacename="" contenttype="" mapdeftoid="false"></inline></matrixtransform><matrixtransform render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" matrix="1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1"><inline render="false" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" url="" load="true" description="" namespacename="" contenttype="" mapdeftoid="false"></inline></matrixtransform><matrixtransform render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" matrix="1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1"><inline render="false" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" url="" load="true" description="" namespacename="" contenttype="" mapdeftoid="false"></inline></matrixtransform><matrixtransform render="true" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" matrix="1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1"><inline render="false" visible="true" bboxcenter="0,0,0" bboxsize="-1,-1,-1" bboxdisplay="false" bboxmargin="0.01" bboxcolor="1,1,0" url="" load="true" description="" namespacename="" contenttype="" mapdeftoid="false"></inline></matrixtransform></scene>',
    'Демо X3D'
),
(
    (SELECT user_id FROM public.users WHERE username = 'Alex'),
    'three.js',
    'Пример Three.js',
    'Описание Three.js сцены',
    'const scene = new THREE.Scene(); const cube = new THREE.Mesh(new THREE.BoxGeometry(), new THREE.MeshBasicMaterial({ color: 0xff0000 })); scene.add(cube);',
    'Демо Three.js'
),
(
    (SELECT user_id FROM public.users WHERE username = 'Alex'),
    'verge3d',
    'Пример Verge3D',
    'Описание Verge3D сцены',
    'https://example.com/verge3d_app/index.html',
    'Демо Verge3D'
);