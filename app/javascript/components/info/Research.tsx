import React from "react";
import { useTranslation } from "react-i18next";
import { logocolors } from "../svgs/Logo";
import { useNavigate } from "react-router";

type Props = {
  height: number;
  width: number;
};

const publications = {
  my_pubs: [
    {
      year: 2021,
      ref: "Modell, M. G. (2021). Improving the Support Provided by a Collaboration Support Platform. In Proceedings of the 52nd ACM Technical Symposium on Computer Science Education (pp. 1370-1370). New York, NY, USA: ACM.",
      title: "Improving the Support Provided by a Collaboration Support Platform",
      link: "https://dl.acm.org/doi/10.1145/3408877.3439555",
      doi: "10.1145/3408877.3439555",
      materials: "https://bit.ly/modell_sigcse_2021"
    },
    {
      year: 2020,
      title: "Bingo! Do we have a winner?",
      ref: "Modell, M. G. (2020). “Bingo!” Do we have a winner? 11(3). 23-35.",
      link: "https://scholarworks.iu.edu/journals/index.php/ijdl/article/view/23976",
      doi: "10.14434/ijdl.v11i3.23976"
    },
    {
      year: 2018,
      title: "Improving Reading Performance Through Gamification and Analytics",
      ref: "Modell, M. G. (2018). Improving Reading Performance Through Gamification and Analytics. In L. Deng, W. Ma, F. W.K., & C. W. Rose (Eds.), New Media for Educational Change (pp. 27–41). Hong Kong: Springer.",
    },
    {
      year: 2017,
      title: "Instructors’ professional vision for collaborative learning groups",
      ref: "Modell, M. G. (2017). Instructors’ professional vision for collaborative learning groups. Journal of Applied Research in Higher Education, 9(3), 346–362",
      link: "https://www.emerald.com/jarhe/article/9/3/346-362/199161",
      doi: "10.1108/JARHE-11-2016-0087"
    },
    {
      year: 2016,
      title: "Learning to Lead Collaborative Student Groups to Success",
      ref: "Modell, M. G. (2016). Learning to Lead Collaborative Student Groups to Success. In C. Martin & D. Polly (Eds.), Handbook of Research on Teacher Education and Professional Development (pp. 187–209). Hershey, PA: IGI Global. ",
      link: "http://doi.org/10.4018/978-1-5225-1067-3.ch010",
      doi: "10.4018/978-1-5225-1067-3.ch010"
    },
    {
      year: 2015,
      title: "Distinguishing between healthy and dysfunctional student project teams: An elusive instructor challenge",
      ref: "Modell, M. G. (2015). Distinguishing between healthy and dysfunctional student project teams: An elusive instructor challenge. Indiana University Bloomington.",
      link: "http://bit.ly/mmodell_dissertation"
    },
    {
      year: 2013,
      title: "Iterating over a method and tool to facilitate equitable assessment of group work",
      ref: "Modell, M. (2013). Iterating over a method and tool to facilitate equitable assessment of group work.International Journal of Designs for Learning, 4(1), 39-53.",
      link: "https://scholarworks.iu.edu/journals/index.php/ijdl/article/view/3283",
      doi: "10.14434/ijdl.v4i1.3283"
    },
    {
      year: 2012,
      title: "Designing a self- and peer-assessment method to equitably grade and reduce social loafing in groups",
      ref: "Modell, M.(November 2012). Designing a self- and peer-assessment method to equitably grade and reduce social loafing in groups at AECT 2012, Louisville, KY."
    }
  ],
  composition: [
    {
      year: 2016,
      title: "Improving collaborative learning in the classroom: Text mining based grouping and representing",
      ref: "Erkens, M., Bodemer, D., & Hoppe, H. U. (2016). Improving collaborative learning in the classroom: Text mining based grouping and representing. International Journal of Computer-Supported Collaborative Learning, 11(4), 387–415.",
      link: "http://doi.org/10.1007/s11412-016-9243-5"
    },

  ],
  gamification: [],
  diversity: []
};

export default function Research(props: Props) {
  const viewBox = [0, 0, 494, 255].join(" ");
  const category = "intro";
  const { t } = useTranslation(category);

  const navigate = useNavigate();
  const [currentTab, setCurrentTab] = React.useState("my_pubs");

  return (
    <svg
      height={props.height}
      width={props.width}
      viewBox={viewBox}
      xmlns="http://www.w3.org/2000/svg"
    >
    <defs>
      <filter id='glow-blur' x="0" y="0" xmlns="http://www.w3.org/2000/svg">
        <feGaussianBlur in='SourceGraphic' stdDeviation="1.5" />
      </filter>
    </defs>
    <g id="main">

      <title>{t("research.title")}</title>
      <text
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="12"
         id="svg_1"
         y="28.5"
         x="30.5"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">{t("research.intro")}</text>
      <text
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="12"
         id="svg_1"
         y="43"
         x="47"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">{t("research.links_too")}</text>
         <g id="tabs">
          {Object.keys(publications).map((key, index) => (
            <g key={key}
              cursor="pointer"
              onClick={() => setCurrentTab(key)}
              id={"tab_" + key}>
                {currentTab === key ? (
              <circle
                cx={140 + (index * 90)} cy="65" r="23"
                filter="url(#glow-blur)"
                fill={logocolors[index % logocolors.length]} />
                ) : null}
              <circle
                cx={140 + (index * 90)} cy="65" r="17"
                stroke="#000" strokeWidth="1"
                fill={logocolors[index % logocolors.length]} />
              <text
                textAnchor="middle"
                fontFamily="Noto Sans JP"
                fontSize="10"
                id={"tab_text_" + key}
                y="66.5"
                x={140 + (index * 90)}
                strokeWidth="1"
                fill="#000">{t("research." + key)}</text>
              <g id="publications">
                {currentTab === key ? (
                  publications[key as keyof typeof publications].map((pub, index) => (
                    <text
                      key={index}
                      textAnchor="start"
                      fontFamily="Noto Sans JP"
                      fontSize="8"
                      id={"pub_" + index}
                      y={100 + (index * 15)}
                      x="115"
                      strokeWidth="0"
                      stroke="#000"
                      fill="#000000"
                      onClick={() => {
                        if (pub.link) {
                          window.open(pub.link, "_blank");
                        }
                      }}
                    >
                      ({pub.year}) {pub.title} 
                    </text>
                  ))
                ) : null}
              </g>
            </g>
          ))}
        </g>
      </g>

    </svg>
  );
}
