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
    {
      year: 2005,
      title: "Distances and diversity: sources for social creativity",
      ref: "Fischer, G. (2005). Distances and diversity: sources for social creativity. Proceedings of the 5th Conference on Creativity & Cognition, 128–136.",
      link: "http://portal.acm.org/citation.cfm?id=1056243"
    },
    {
      year: 2012,
      title: "Fostering Team Creativity: Perspective Taking as Key to Unlocking Diversity’s Potential",
      ref: "Hoever, I. J., van Knippenberg, D., van Ginkel, W. P., & Barkema, H. G. (2012). Fostering Team Creativity: Perspective Taking as Key to Unlocking Diversity’s Potential. Journal of Applied Psychology, 97(5), 982–996.",
      link: "http://doi.org/10.1037/a0029159"
    },
    {
      year: 2004,
      title: "Turning student groups into effective teams",
      ref: "Oakley, B. A., Felder, R. M., Brent, R., & Elhajj, I. (2004). Turning student groups into effective teams. Journal of Student Centered Learning, 2(1), 9–34."
    },
    {
      year: 2002,
      title: "Project team formation processes: Student attitudes and experiences in nine alternative methods",
      ref: "Nicholson, C. Y., Oliphant, G. C., & Oliphant, R. J. (2002). Project team formation processes: Student attitudes and experiences in nine alternative methods. Journal of the Academy of Business Education, 3."
    },
    {
      year: 2005,
      title: "The development of innovative teaching methods, informed group structures and fair assessment models for the teaching of group design projects",
      ref: "Tucker, R. (2005). The development of innovative teaching methods, informed group structures and fair assessment models for the teaching of group design projects. In AASA 2005 : Drawing together : convergent practices in architectural education, Proceedings of the 3rd International Conference of the Association of Architectural Schools of Australasia (pp. 1–9). Brisbane, QLD: Queensland University of Technology."
    },
    {
      year: 2006,
      title: "The impact of teaching models, group structures and assessment modes on cooperative learning in the student design studio",
      ref: "Tucker, R., & Reynolds, C. (2006). The impact of teaching models, group structures and assessment modes on cooperative learning in the student design studio. Journal for Education in the Built Environment, 1(2), 39–56."
    },
    {
      year: 2011,
      title: "A team building model for software engineering courses term projects",
      ref: "Sahin, Y. G. (2011). A team building model for software engineering courses term projects. Computers & Education, 56(3), 916–922.",
      link: "http://doi.org/10.1016/j.compedu.2010.11.006",
      doi: "10.1016/j.compedu.2010.11.006"
    },
    {
      year: 2011,
      title: "Tapping the benefits of multicultural group work: An exploratory study of postgraduate management students",
      ref: "Woods, P., Barker, M., & Hibbins, R. (2011). Tapping the benefits of multicultural group work: An exploratory study of postgraduate management students. The International Journal of Management Education, 9(February 2010), 59–70.",
      link: "http://doi.org/10.3794/ijme.92.317",
      doi: "10.3794/ijme.92.317"
    }
  ],
  gamification: [
    {
      year: 2001,
      title: "Peer Instruction: Ten years of experience and results",
      ref: "Crouch, C. H., & Mazur, E. (2001). Peer Instruction: Ten years of experience and results. American Journal of Physics, 69(9), 970.",
      link: "https://doi.org/10.1119/1.1374249",
      doi: "10.1119/1.1374249"
    },
    {
      year: 2017,
      title: "Gamifying education: what is known, what is believed and what remains uncertain: a critical review",
      ref: "Dichev, C., & Dicheva, D. (2017). Gamifying education: what is known, what is believed and what remains uncertain: a critical review. International Journal of Educational Technology in Higher Education (Vol. 14). International Journal of Educational Technology in Higher Education.",
      link: "https://doi.org/10.1186/s41239-017-0042-5",
      doi: "10.1186/s41239-017-0042-5"
    },
    {
      year: 2005,
      title: "Pedagogies of uncertainty",
      ref: "Shulman, L. S. (2005). Pedagogies of uncertainty. Liberal Education, 18–25."
    },
    {
      year: 2014,
      title: "Does gamification work? - A literature review of empirical studies on gamification",
      ref: "Hamari, J., Koivisto, J., & Sarsa, H. (2014). Does gamification work? - A literature review of empirical studies on gamification. Proceedings of the Annual Hawaii International Conference on System Sciences, (JANUARY), 3025–3034.",
      link: "https://doi.org/10.1109/HICSS.2014.377",
      doi: "10.1109/HICSS.2014.377"
    },
    {
      year: 2015,
      title: "Usage of Gamification Theory for Increase Motivation of Employees",
      ref: "Kamasheva, A. V., Valeev, E. R., Yagudin, R. K., & Maksimova, K. R. (2015). Usage of Gamification Theory for Increase Motivation of Employees. Mediterranean Journal of Social Sciences, 6(1), 77–80.",
      link: "https://doi.org/10.5901/mjss.2015.v6n1s3p77",
      doi: "10.5901/mjss.2015.v6n1s3p77"
    },
    {
      year: 2012,
      title: "A User-Centered Theoretical Framework for Meaningful Gamification",
      ref: "Nicholson, S. (2012). A User-Centered Theoretical Framework for Meaningful Gamification. Games+ Learning+ Society, 1–7.",
      link: "https://doi.org/10.1007/978-3-319-10208-5_1",
      doi: "10.1007/978-3-319-10208-5_1"
    },
    {
      year: 2015,
      title: "Game on: Engaging customers and employees through gamification",
      ref: "Robson, K., Plangger, K., Kietzmann, J. H., McCarthy, I., & Pitt, L. (2015). Game on: Engaging customers and employees through gamification. Business Horizons, (AUGUST).",
      link: "https://doi.org/10.1016/j.bushor.2015.08.002",
      doi: "10.1016/j.bushor.2015.08.002"
    },
    {
      year: 2011,
      title: "“This Game Sucks”: How to Improve the Gamification of Education",
      ref: "Smith-Robbins, S. (2011). “This Game Sucks”: How to Improve the Gamification of Education. ",
      link: "http://www.educause.edu/EDUCAUSE+Review/EDUCAUSEReviewMagazineVolume46/ThisGameSucksHowtoImprovetheGa/222665"
    }
  ],
  diversity: [
    {
      year: 2011,
      title: "The mechanisms of collaboration in inventive teams: Composition, social networks, and geography",
      ref: "Bercovitz, J., & Feldman, M. (2011). The mechanisms of collaboration in inventive teams: Composition, social networks, and geography. Research Policy, 40(1), 81–93.",
      link: "http://doi.org/10.1016/j.respol.2010.09.008",
      doi: "10.1016/j.respol.2010.09.008"
    },
    {
      year: 2000,
      title: "Perspective-taking: Decreasing stereotype expression, stereotype accessibility, and in-group favoritism",
      ref: "Galinsky, A. D., & Moskowitz, G. B. (2000). Perspective-taking: Decreasing stereotype expression, stereotype accessibility, and in-group favoritism. Journal of Personality and Social Psychology, 78(4), 708–724.",
      link: "http://doi.org/10.1037//0022-3514.78.4.708",
      doi: "10.1037/0022-3514.78.4.708"
    },
    {
      year: 1959,
      title: "Homogeneity of member personality and its effect on group problem-solving",
      ref: "Hoffman, L. R. (1959). Homogeneity of member personality and its effect on group problem-solving. The Journal of Abnormal and Social Psychology, 58(1), 27–32."
    },
    {
      year: 1996,
      title: "Effect of perspective taking on the cognitive representation of persons: a merging of self and other",
      ref: "Davis, M. H., Conklin, L., Smith, A., & Luce, C. (1996). Effect of perspective taking on the cognitive representation of persons: a merging of self and other. Journal of Personality and Social Psychology, 70(4), 713–726.",
      link: "http://doi.org/10.1037/0022-3514.70.4.713",
      doi: "10.1037/0022-3514.70.4.713"
    },
    {
      year: 2015,
      title: "Gender Differences in Recognition for Group Work",
      ref: "Sarsons, H. (2015). Gender Differences in Recognition for Group Work. Harvard Working Paper Series.",
      link: "http://www.nytimes.com/2016/01/10/upshot/when-teamwork-doesnt-work-for-women.html?_r=0%5Cnhttp://scholar.harvard.edu/files/sarsons/files/gender_groupwork.pdf?m=1449178759"
    },
    {
      year: 2003,
      title: "Joint Impact of Interdependence and Group Diversity on Innovation",
      ref: "Van der Vegt, G. S., & Janssen, O. (2003). Joint Impact of Interdependence and Group Diversity on Innovation. Journal of Management, 29(5), 729–751.",
      link: "http://doi.org/10.1016/S0149-2063_03_00033-3",
      doi: "10.1016/S0149-2063_03_00033-3"
    },
    {
      year: 2011,
      title: "Tapping the benefits of multicultural group work: An exploratory study of postgraduate management students",
      ref: "Woods, P., Barker, M., & Hibbins, R. (2011). Tapping the benefits of multicultural group work: An exploratory study of postgraduate management students. The International Journal of Management Education, 9(February 2010), 59–70.",
      link: "http://doi.org/10.3794/ijme.92.317",
      doi: "10.3794/ijme.92.317"
    },
    {
      year: 2011,
      title: "What Makes a Team Better? More Women",
      ref: "Woolley, A. W., & Malone, T. (2011). What Makes a Team Better? More Women. Harvard Business Review, Vol. 89, (June).",
    }

  ]
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
                  publications[key as keyof typeof publications]
                    .sort((a, b) => b.year - a.year)
                    .map((pub, index) => (
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
                      cursor={pub.link ? "pointer" : "default"}
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
