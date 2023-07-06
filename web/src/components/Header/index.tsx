import HeroSlider from '#components/HeroSlider'
import { CurriculumVitaeProperties, Picture } from '#components/CurriculumVitae'
import styles from './index.module.css'

interface Properties {
	data: CurriculumVitaeProperties
}

const Header = ({ data }: Properties) => {
	return (
		<header className={styles.header}>
			<HeroSlider images={data.pictures || []} />
		</header>
	)
}

export default Header
