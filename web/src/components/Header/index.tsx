import HeroSlider from '#components/HeroSlider'
import { CurriculumVitaeProperties, Picture } from '#components/CurriculumVitae'
import styles from './index.module.css'

interface Properties {
	data: CurriculumVitaeProperties
}

const Header = ({ data }: Properties) => {
	return data.pictures && data.pictures.length > 0 ? (
		<header className={styles.header}>
			<HeroSlider images={data.pictures || []} />
		</header>
	) : null
}

export default Header
