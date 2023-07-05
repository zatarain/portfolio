import HeroSlider from '#components/HeroSlider'
import { CurriculumVitaeProperties, Picture } from '#components/CurriculumVitae'
import styles from './index.module.css'

interface Properties {
	data: CurriculumVitaeProperties
}

const Header = ({ data }: Properties) => {
	const pictures = data.pictures || [];
	const images = pictures.reduce((result: object, picture: Picture) => {
		return {
			...result,
			[`Image ${picture.id}`]: picture.media_url,
		}
	}, {})

	return (
		<header className={styles.header}>
			<HeroSlider images={images} />
		</header>
	)
}

export default Header
