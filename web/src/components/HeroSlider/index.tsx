import { Carousel } from 'react-responsive-carousel';
import Image from 'next/image';
import styles from './index.module.css'
import { Picture } from '#components/CurriculumVitae';
interface Properties {
	images: Picture[]
}

const HeroSlider = ({ images }: Properties) => {
	return (
		<Carousel
			animationHandler="fade"
			autoPlay={true}
			showThumbs={false}
			showStatus={false}
			transitionTime={1000}
			interval={7000}
			showArrows={false}
			infiniteLoop={true}
			stopOnHover={true}
			swipeable={true}
			className={styles.hero}
		>
			{
				images.map((picture: Picture, index: number) => (
					<figure key={index}>
						<Image src={picture.media_url} alt={picture.caption} width={1440} height={768} />
						<figcaption>{picture.caption.replaceAll(/#[^ ]+/g, '').trim()}</figcaption>
					</figure>
				))
			}
		</Carousel>
	)
}

export default HeroSlider
